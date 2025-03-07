---
date : '2025-03-07T20:02:29+01:00'
title : "I wrote a Polars plugin - and it's easier than you think"
summary: "My first Polars plugin, `polars-argpartition`"
description: "The description of my first Polars plugin"
toc: false
readTime: true
autonumber: false
math: false
tags: ["python", "polars", "rust", "numpy", "argpartition"]
showTags: false
---

[Polars](https://pola.rs/) is an excellent DataFrame library, written in Rust, and it has become my go-to tool for data manipulation in Python. It's fast, has a clean syntax and offers powerful capabilities that, in many ways, make it superior to Pandas.

One feature that many people overlook is the ability to extend its functionality with [custom plugins](https://docs.pola.rs/user-guide/plugins/).

The idea is simple: Polars is shipped with a rich set of functions and options that cover 99% of common use cases. However, there are times when you might still need to implement some custom logic for which prebuilt functions are not enough.

In those cases, you have two options:
- Implement it in Python using [`map_elements`](https://docs.pola.rs/api/python/dev/reference/expressions/api/polars.Expr.map_elements.html).
- Implement it in Rust, register the function as a plugin and use it seamlessly in your expressions.

[The documentation](https://docs.pola.rs/user-guide/expressions/user-defined-python-functions/) makes it clear that the first option should always be avoided: `map_elements` is slow and doesn't support lazy execution.

That said, writing a plugin in Rust requires knowing Rust. For those used to Python, Rust can feel like a steep learning curve.

But here’s the good news: if your logic isn’t too complex, you don’t need to be a Rust expert. This [fantastic guide](https://marcogorelli.github.io/polars-plugins-tutorial/) by Marco Gorelli takes you 90% of the way there (and another 7/8% can be covered with LLMs 🙃).

Thanks to these tools, I was able to build my own Polars plugin, `polars-argpartition`!

## The plugin - `polars-argpartition`

I was looking for a way to implement the NumPy [`argpartition`](https://numpy.org/doc/stable/reference/generated/numpy.argpartition.html) function directly in a Polars DataFrame, without extracting the column into an array. 

This function is useful when you need to retrieve the top *k* elements of an array without caring about the order of the rest of the array.

The algorithm itself is complex, but, luckily, Rust standard library provides a function that does exactly that, [`select_nth_unstable`](https://doc.rust-lang.org/std/primitive.slice.html#method.select_nth_unstable). 

This means that the plugin only needs to call it!

[Here](https://github.com/GiovanniGiacometti/polars-argpartition) you can find the Github Repository with the code.

[Here](https://pypi.org/project/polars-argpartition/) the PyPI page.

You can install the plugin with any package manager, like `uv`:

```bash
uv add polars-argpartition
```

Then, you can use it in your Python code like this:

```python
import polars as pl
from polars_argpartition import argpartition

df = pl.DataFrame(
    {
        "a": [1, 3, 6, 2, 5, 10, 12],
    }
)

k = 3

print(
    df.with_columns(
        idxs=argpartition(
            -pl.col("a"),
            k=k,
        )
    )
    .with_row_index(name="row_index")
    .filter(pl.col("row_index").is_in(pl.col("idxs").slice(0, k)))
    .select(["a"])
)

```

This code applies the argpartition function to the column `a` and retains only the top 3 elements. This is faster than sorting the whole array, especially when you have a large number of elements.

The output will be (the order of the elements might change):

```
shape: (3, 1)
┌──────┐
│ a    │
│ ---  │ 
│ i64  │
╞══════╡
│ 6    │
│ 10   │
│ 12   │ 
└──────┘

# i'm aware the markdown is not rendered 
# perfectly, i'm investigating 🤔 

```

--- 

I hope this example helps you understand how easy it is to write a Polars plugin. If you have any questions, feel free to ask in the comments below!