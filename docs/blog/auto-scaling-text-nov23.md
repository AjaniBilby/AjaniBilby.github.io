---
draft: true
title: CSS Auto Font Scaling
description: Resizing text to fit the space
date: 2023-11-15
tags:
	- CSS
hide:
	- navigation
---

# CSS Auto Font Scaling

The new [CSS Container Queries](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_container_queries)
are actually much more useful than for just switching between different discrete CSS styles.
They can actually be easily repurposed for other things such as dynamic font sizing to stop text from clipping off the screen

<style>
	.boundary {
		display: flex;
		flex-wrap: wrap;
		align-content: flex-start;
		align-items: flex-end;
		gap: 0.5em 1em;

		width: 300px;
		height: 250px;
		max-width: 100%;
		background-color: var(--md-code-bg-color);
		padding: 0 15px;

		font-size: 14pt; /*fallback*/

		--char-aspec-ratio: 1.8;
	}

	.boundary.animated {
		animation: expand 3s ease-in infinite alternate;
	}

	.scaler {
		container-type: inline-size;
	}

	.asf {
		font-size: min(60px, calc(100cqw / var(--chars) * var(--char-aspec-ratio)));
		font-family: monospace;
	}

	/* Define the keyframes for the animation */
	@keyframes expand {
		from {
			width: 5%;
		}
		to {
			width: calc(100% - 30px);
		}
	}
</style>
<div>
	<div class="boundary scaler animated">
		<div class="asf" style="--chars: 2">
			hi
		</div>
		<div class="asf" style="--chars: 7">
			because
		</div>
		<div class="asf" style="--chars: 45">
			pneumonoultramicroscopicsilicovolcanoconiosis
		</div>
	</div>
</div>

```css title="css"
.scaler {
	font-size: 14pt; /*fallback*/
	container-type: inline-size;
	--char-aspec-ratio: 1.8;
}

.auto-scaling-font {
	font-size: min(
		60px,
		calc(100cqw / var(--chars) * var(--char-aspec-ratio))
	);
}
```
```html title="html"
<div class="boundary scaler">
	<div class="auto-scaling-font" style="--chars: 2">
		hi
	</div>
	<div class="auto-scaling-font" style="--chars: 7">
		because
	</div>
	<div class="auto-scaling-font" style="--chars: 45">
		pneumonoultramicroscopicsilicovolcanoconiosis
	</div>
</div>
```