---
date : '2025-02-11T00:00:00Z'
title : 'A Python repository template, based on uv and Just'
summary: "How Just and UV are simplifying my development life"
description: "The description of my python repository template, based on UV and Just"
toc: true
readTime: true
autonumber: false
math: false
tags: ["python", "template", "uv", "just", "ruff", "docker", "github"]
showTags: false
---

A repository template is a [Github feature](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template)
that allows you to create a new repository with the same directory structure and files as the template repository.

This can be incredibly useful, as it lets you skip the boring setup process and dive straight into building your project.

I recently created a Python repository template, which you can check out in this [repository](https://github.com/GiovanniGiacometti/python-repo-template).
While you're welcome to fork it and use it as is,
I highly recommend building your own template tailored to your specific needs and preferences. 
After all, it’s unlikely that a template made by someone else will perfectly match your requirements.

The goal of this blog post is to explain the decisions I made while creating my template, which I hope will inspire you or at least foster some curiosity.

I also shared this template in the [r/Python](https://www.reddit.com/r/Python/comments/1ime8ja/a_modern_python_repository_template_with_uv_and/) 
subreddit. I will address some of the feedback I received in the comments here, 
but I encourage you to check out the original post as well, as the discussion contains valuable insights.

## Foundations

The template is built on two main pillars: [uv](https://docs.astral.sh/uv/) and [Just](https://github.com/casey/just).

`uv` doesn't need any introduction: quoting its official documentation, it's "an extremely fast Python package and 
project manager, written in Rust". Despite being relatively new (it was released in February 2024) it's rapidly becoming
the de-facto standard for Python package management, replacing famous well-established tool like `pip`, `poetry` or `pdm`. 

`Just` is a command runner inspired by `make`, but with a simpler syntax and many improvements. It allows you to define 
recipes that can accept arguments and even supports writing recipes in various languages, such as Python. Like uv, it’s also written in Rust
 (it looks like it's becoming a thing).

>  The choice of Just was one of the most debated topics in the Reddit discussion. A *huge* number of alternatives were suggested, 
>  such as `pyinvoke`, `taskfile` or `poethepoet`. Some argued against installing another command runner, insisting that `make`
>  was enough for their needs. Others even claimed that command runners are not needed at all, "since you can just define
>  shell scripts" (???). 
>
>  To be honest, I wasn't aware of all these alternatives when I made my choice. I wanted to find an alternative to `make`,
>  and I found `Just` to be the most promising. I'm happy with my decision, but I don’t expect it to be the ideal choice for everyone.-
>  As mentioned before, I encourage you to explore different options and choose the one that suits you best.


## Development Tools

## Infrastructure




