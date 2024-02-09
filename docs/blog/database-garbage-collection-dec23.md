---
title: Implementing Database level garbage collection for Blobs
description: How to implement a garbage collector at a database level for managing media uploads and other entities
date: 2023-12-13
tags:
  - Database
  - SQL
  - Garbage Collection
  - S3 Storage
hide:
  - navigation
---

Something that I often see for media management of online services I use is these two lazy solutions for managing uploaded user media:

  - File Expiry: WHen a user uploads a file it has a fixed duration until that file disappears, and the app just relies on the fact that hopefully you won't try to load content that is older than the period of time they set.
  - Single File Ownership: If a file is uploaded in a certain post/message or other entity, it's existence is tied to the lifetime of the thing it was originally uploaded to. Meaning if that image was then reused else where, when the original post is deleted all other entities that used that media now have a missing image.
  - Infinite Storage: Services at Facebook/Google/Discord scale often opt for this approach, which is just don't delete anything, because the operating cost of storing media infinitely is less costly than the potential development slow down of actually having garbage collection system.

Ideally want you want is to track where certain media is being used, then when it is no longer being used anywhere, it is then deleted. However this can lead to some instant implementation bottle necks. If all of your posts/comments/etc are all stored in the database, then that means you need to scan the entire database to ensure a certain piece of media is no longer used? No, you can actually exploit some properties of foreign keys to get sweeping for free without room for developer error as the system is maintained.

!!! note "Side Note"

    I'm not so bold or foolish to say the potential solution I am going to propose is perfect or all use cases, that is why I will describe a few variations which could be helpful at different scales, but even then there will still be cases where none of these solutions are optimal for some very specific use cases.

## Naive Approach

The naive approach would be to make a query which checks anywhere a specific media (aka blob) can be used, and then gather a list of distinct in use blobIDs then from that we then know which media we can delete (everything not in the list). But that leaves a potential massive issue of maintainability.

What happens when you add a new entity which uses a blob? If someone forgets to add it into this big query you'll end up with media prematurely being deleted because it's not correctly checked if it's in use.

Ideally we want an implementation where it doesn't matter how many new ways you add to use a blob, it can easily be tied into this garbage collector without room for error.

## Referencing a Blob

The database already has ways to tie different rows together linking them, so it knows which tables might possibly link to a given row, and also indexes which rows link to it. We can leverage this to ensure that a blob can never be deleted when a row in another table still references it.

We can do this with a simple `ON DELETE RESTRICT` foreign key link, we can see in the high level prisma abstraction of our database structure we have our `m:n` joining table between `Blob <-> Post` has a cascade on it's deletion of post, and a restrict on the deletion of a blob. This means this joining table will prevent blobs from being deleted when a post references them, but when a post is deleted, this reference is then also deleted.

```prisma title="schema.prisma"
model Blob {
	id            String @id @default(dbgenerated("generate_blob_id()")) @db.VarChar(11)
	filename      String @db.VarChar(255)
	mimetype      String @db.VarChar(255)

	// Computed values
	visibility VisibilityType @default(PRIVATE)
	unused     Boolean @default(false)
	updatedAt DateTime @default(now()) @updatedAt
}

model BlobAttachment {
	id Int @default(autoincrement()) @id

	blob     Blob   @relation(fields: [blobID], references: [id], onUpdate: Cascade, onDelete: Restrict)
	blobID   String @db.VarChar(11)

	post      Post?   @relation(fields: [postID], references: [id], onUpdate: Cascade, onDelete: Cascade)
	postID   String?
	@@unique([postID, blobID])
}
```

## Marking for Deletion

Now we have a method that prevents a blob from being deleted from the database when it's in use, but how can we detect which blobs are able to be deleted so we can then delete them from our actual storage, and then remove them from the database? You try and delete it.

We'll start of with the simple case of a single blob, first of all we store the row we want to delete in memory, then we try and delete it, if the delete is successful we reinsert the value back into the database changing `unused` to `true`, and if we had an exception trying to deleted it, we can update `used` to false. We're able to do all of this most importantly in a single SQL query, we didn't need to transfer any information about the blob state across the network.

You might also notice there is a bit of extra code in the successful deletion case which checks if we're going to change the `unused` status, and if so then we also change the `updatedAt` value to `now()`, we only do this when the value changes so that we can track how long ago something was marked.

```sql title="Mark Single"
DO $$
DECLARE
  v_blob "Blob"%ROWTYPE;
BEGIN
  BEGIN
    -- Store the record into the variable
    SELECT * INTO v_blob FROM "Blob" WHERE id = $1;

    -- Try to delete the record
    DELETE FROM "Blob" WHERE id = $1;

    -- If successful, insert the record back and mark unused as TRUE
    INSERT INTO "Blob" ("id", "filename", "mimetype", "unused", "updatedAt", "createdAt")
    VALUES (
      v_blob."id", v_blob."filename", v_blob."mimetype", TRUE,
      CASE
        WHEN v_blob."unused" = FALSE THEN now()
        WHEN v_blob."unused" = TRUE THEN v_blob."updatedAt"
      END,
      v_blob."createdAt"
    );

  EXCEPTION WHEN foreign_key_violation THEN
    -- If DELETE fails due to foreign key violation, set the unused flag to FALSE
    UPDATE "public"."Blob" b
    SET "updatedAt" = CASE
        WHEN b."unused" = TRUE THEN now()
        WHEN b."unused" = FALSE THEN b."updatedAt"
      END,
      "unused" = FALSE
    WHERE id = $1;
  END;
END;
$$;
```

Now we can scale this up, looping over every row in the `Blob` table doing the same thing, now we're able to update mark every blob in a table with a single sql query.

```sql title="Mark All"
DO $$
DECLARE
	v_blob "Blob"%ROWTYPE;
	v_blob_cursor CURSOR FOR SELECT * FROM "Blob";
BEGIN
	-- Open the cursor to iterate through all blobs
	OPEN v_blob_cursor;

	LOOP
		-- Fetch next blob record
		FETCH v_blob_cursor INTO v_blob;

		-- Exit loop if no more blobs
		EXIT WHEN NOT FOUND;

		BEGIN
			-- Try to delete the record
			DELETE FROM "Blob" WHERE id = v_blob.id;

			-- If successful, insert the record back and mark unused as TRUE
			INSERT INTO "Blob" ("id", "filename", "mimetype", "unused", "updatedAt", "createdAt")
			VALUES (
				v_blob."id", v_blob."filename", v_blob."mimetype", TRUE,
				CASE
					WHEN v_blob."unused" = FALSE THEN now()
					WHEN v_blob."unused" = TRUE THEN v_blob."updatedAt"
				END,
				v_blob."createdAt"
			);

		EXCEPTION WHEN foreign_key_violation THEN
			-- If DELETE fails due to foreign key violation, set the unused flag to FALSE
			UPDATE "public"."Blob" b
			SET "updatedAt" = CASE
					WHEN "unused" = TRUE  THEN now()
					WHEN "unused" = FALSE THEN b."updatedAt"
				END,
				"unused" = FALSE
			WHERE id = v_blob.id;
		END;

	END LOOP;

	-- Close the cursor
	CLOSE v_blob_cursor;
END;
$$;
```

## Sweeping

Now that we have marked all of the blobs, we can get a simple list of all items which weren't swept recently. This grace period is important for multiple reasons the biggest one being: a new blob item could have been uploaded but the record linking to it has not yet been saved. Hence we have a grace period to ensure something hasn't gone wrong.
```sql title="Get Sweepable"
SELECT "id"
FROM "Blob"
WHERE "unused" = TRUE
AND "updatedAt" < CURRENT_DATE - INTERVAL '1 days';
```

Now we have the list of `Blob.id`s which are ready for deletion and we can use these to delete the actual files from our S3 bucket or equivalent storage. But how were these IDs originally made in such a way that they perfectly make the name they were given in our bucket without conflict?

## Uploading


## Blob Access in Code

```ts
import { BlobPagePoll } from "./page-using-blob.server";
import { Blob } from "@prisma/client";

export function BlobPath(blobID: Blob['id'], __filename: string, thumbnail: boolean) {
	if (typeof BlobPagePoll !== 'undefined') BlobPagePoll(blobID, __filename);

	if (thumbnail) return `/blob/${blobID}/thumbnail`;
	return `/blob/${blobID}/raw`;
}
```

```ts
export async function BlobPagePoll(blobID: Blob['id'], url: string) {
	if (process.env.NODE_ENV !== "production") return;

	await limiter.allocate(); // one page update at a time

	await prisma.pageUsingBlob.upsert({
		where: { blobID_url: { blobID, url } },
		create: {
			blobID: blobID,
			url: url,
			inUse: true,
		},
		update: { inUse: true, }
	});

	await prisma.blob.update({
		where: { id: blobID },
		data: { visibility: "PUBLIC" }
	});

	limiter.free();
}

export async function SweepPages() {
	if (process.env.NODE_ENV !== "production") return;

	const past30days = new Date();
	past30days.setDate(past30days.getDate() - 30);
	const [ removed, _ ] = await prisma.$transaction([
		prisma.pageUsingBlob.findMany({
			where: {
				inUse: false,
				updatedAt: { lt: past30days }
			}
		}),
		prisma.pageUsingBlob.deleteMany({
			where: {
				inUse: false,
				updatedAt: { lt: past30days }
			}
		})
	]);

	await UpdateBlobVisibilities(removed.map(x => x.blobID));
}
```