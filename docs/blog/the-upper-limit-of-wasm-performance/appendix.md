# Appendix: Implementing Database level garbage collection for Blobs

[Article](/blog/the-upper-limit-of-wasm-performance/)

## Benchmark Source

```c title="server.c"
--8<-- "docs/blog/the-upper-limit-of-wasm-performance/server.c"
```

```c title="server.wat"
--8<-- "docs/blog/the-upper-limit-of-wasm-performance/server.wat"
```

[Other Benchmarks](https://github.com/wasmerio/winterjs/tree/main/benchmark)

## Raw Results

### WebAssembly (wasmer runtime)

```bash
wasmer server.wasm --net
```

```
Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    26.55ms  128.64ms   1.77s    95.69%
    Req/Sec     1.99k     1.30k   29.42k    83.84%
  236457 requests in 10.10s, 8.12MB read
  Socket errors: connect 0, read 236457, write 0, timeout 37
Requests/sec:  23413.55
Transfer/sec:    823.16KB

Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    10.13ms   73.05ms   1.76s    98.36%
    Req/Sec     1.92k     1.18k    6.46k    65.69%
  226805 requests in 10.07s, 7.79MB read
  Socket errors: connect 0, read 226805, write 0, timeout 12
Requests/sec:  22533.68
Transfer/sec:    792.23KB

Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    13.71ms   83.90ms   1.77s    97.23%
    Req/Sec     2.03k     1.34k   18.36k    72.21%
  236314 requests in 10.10s, 8.11MB read
  Socket errors: connect 0, read 236315, write 0, timeout 19
Requests/sec:  23397.43
Transfer/sec:    822.60KB
```

### WebAssembly (wasmer llvm)

```bash
wat2wasm server.wat -o server.wasm
wasmer create-exe --llvm server.wasm -o server.out
```

```
Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    20.35ms  117.18ms   1.77s    96.60%
    Req/Sec     2.51k     1.77k   34.89k    80.43%
  299600 requests in 10.10s, 10.29MB read
  Socket errors: connect 0, read 299600, write 0, timeout 39
Requests/sec:  29665.16
Transfer/sec:      1.02MB

Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    17.29ms  106.60ms   1.76s    97.06%
    Req/Sec     2.50k     1.29k   14.02k    77.21%
  301093 requests in 10.10s, 10.34MB read
  Socket errors: connect 0, read 301093, write 0, timeout 23
Requests/sec:  29811.75
Transfer/sec:      1.02MB

Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    22.95ms  123.38ms   1.77s    96.22%
    Req/Sec     2.47k     1.64k   36.88k    84.55%
  296337 requests in 10.10s, 10.17MB read
  Socket errors: connect 0, read 296337, write 0, timeout 30
Requests/sec:  29339.53
Transfer/sec:      1.01MB
```

### Winter.js (wasmer runtime)

```
Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    55.14ms    8.91ms 165.95ms   93.45%
    Req/Sec   396.56    138.06   680.00     62.94%
  47648 requests in 10.05s, 5.47MB read
Requests/sec:   4740.14
Transfer/sec:    556.95KB

Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    50.93ms    6.07ms 215.99ms   84.28%
    Req/Sec   200.83    106.82   686.00     68.49%
  24136 requests in 10.04s, 2.77MB read
Requests/sec:   2403.87
Transfer/sec:    282.71KB

Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    52.97ms    9.61ms 251.05ms   90.47%
    Req/Sec   112.27     79.62   400.00     65.18%
  13092 requests in 10.04s, 1.50MB read
Requests/sec:   1304.06
Transfer/sec:    153.45KB
```

### Node

```
Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    45.82ms  177.25ms   1.99s    95.62%
    Req/Sec     2.88k   835.90    11.15k    90.74%
  325385 requests in 10.03s, 53.37MB read
  Socket errors: connect 0, read 0, write 0, timeout 43
Requests/sec:  32447.16
Transfer/sec:      5.32MB

Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    45.24ms  171.77ms   2.00s    95.86%
    Req/Sec     2.49k   816.56    11.11k    90.42%
  280164 requests in 10.06s, 45.96MB read
  Socket errors: connect 0, read 0, write 0, timeout 64
Requests/sec:  27851.09
Transfer/sec:      4.57MB

Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    43.95ms  168.63ms   1.99s    95.99%
    Req/Sec     2.51k     0.88k   17.13k    90.40%
  283702 requests in 10.06s, 46.54MB read
  Socket errors: connect 0, read 0, write 0, timeout 60
Requests/sec:  28193.25
Transfer/sec:      4.62MB
```

### Bun

```
Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     3.21ms    1.11ms  40.54ms   97.62%
    Req/Sec    10.44k   699.00    16.63k    85.83%
  1254427 requests in 10.06s, 143.56MB read
Requests/sec: 124727.81
Transfer/sec:     14.27MB

Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     3.48ms  362.15us  11.16ms   80.94%
    Req/Sec     9.52k   506.77    18.89k    94.37%
  1143770 requests in 10.06s, 130.89MB read
Requests/sec: 113749.38
Transfer/sec:     13.02MB

Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     3.14ms  382.54us   8.30ms   84.57%
    Req/Sec    10.57k   786.85    20.00k    97.35%
  1268543 requests in 10.02s, 145.17MB read
Requests/sec: 126545.76
Transfer/sec:     14.48MB
```

### C (gcc -O0)

```
Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    21.26ms  117.42ms   1.77s    95.95%
    Req/Sec     4.73k     2.65k   16.46k    72.86%
  562425 requests in 10.10s, 17.16MB read
  Socket errors: connect 0, read 562425, write 0, timeout 36
Requests/sec:  55685.12
Transfer/sec:      1.70MB

Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    27.25ms  143.89ms   1.77s    95.87%
    Req/Sec     4.85k     2.46k   17.69k    66.83%
  579112 requests in 10.10s, 17.67MB read
  Socket errors: connect 0, read 579112, write 0, timeout 35
Requests/sec:  57339.04
Transfer/sec:      1.75MB

Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    26.16ms  124.31ms   1.77s    95.02%
    Req/Sec     4.84k     2.82k   34.01k    75.42%
  574902 requests in 10.10s, 17.55MB read
  Socket errors: connect 0, read 574902, write 0, timeout 32
Requests/sec:  56920.29
Transfer/sec:      1.74MB
```

### C (gcc -O3)

```
Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    18.98ms  115.87ms   1.76s    96.51%
    Req/Sec     5.00k     2.96k   29.10k    74.96%
  594236 requests in 10.10s, 18.13MB read
  Socket errors: connect 0, read 594236, write 0, timeout 28
Requests/sec:  58834.45
Transfer/sec:      1.80MB

Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    20.99ms  119.09ms   1.77s    96.18%
    Req/Sec     5.00k     2.87k   24.91k    74.08%
  594872 requests in 10.10s, 18.15MB read
  Socket errors: connect 0, read 594872, write 0, timeout 43
Requests/sec:  58899.79
Transfer/sec:      1.80MB

Running 10s test @ http://127.0.0.1:8080
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    21.32ms  125.58ms   1.77s    96.48%
    Req/Sec     5.15k     3.13k   18.28k    71.01%
  597622 requests in 10.10s, 18.24MB read
  Socket errors: connect 0, read 597622, write 0, timeout 47
Requests/sec:  59175.08
Transfer/sec:      1.81MB
```