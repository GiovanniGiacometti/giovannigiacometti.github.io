---
date : '2025-02-15T00:00:00Z'
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

I recently created a Python repository template, which you can check out in [this repository](https://github.com/GiovanniGiacometti/python-repo-template).
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
commands that can accept arguments and even supports writing recipes in various languages, such as Python. Like uv, it’s also written in Rust
 (it looks like it's becoming a thing).

>  The choice of Just was one of the most debated topics in the Reddit discussion. A *huge* number of alternatives were suggested, 
>  such as `pyinvoke`, `taskfile` or `poethepoet`. Some argued against installing another command runner, insisting that `make`
>  was enough for their needs. Others even claimed that command runners are not needed at all, since "you can just define
>  shell scripts" (???). 
>
>  To be honest, I wasn't aware of all these alternatives when I made my choice. I wanted to find an alternative to `make`,
>  and I found `Just` to be the most promising. I'm happy with my decision, but I don’t expect it to be the ideal choice for everyone.
>  As mentioned before, I encourage you to explore different options and choose the one that suits you best.


## Development Tools

Let's now go over the development tools I included in the template. Most of these can be invoked using Just commands. For more details, check out the [README.md](https://github.com/GiovanniGiacometti/python-repo-template/blob/main/README.md).

- [`Ruff`](https://docs.astral.sh/ruff/): an extremely fast linter and code formatter.

- [`MyPy`](https://mypy.readthedocs.io/en/stable/): a static type checker for Python. All the code I write has type hints, which means that MyPy is a must-have tool for me.

> I was asked why both Ruff and MyPy are needed. The answer is simple: they do different things. You can find a more detailed explanation in Ruff's [documentation](https://docs.astral.sh/ruff/faq/#how-does-ruff-compare-to-mypy-or-pyright-or-pyre)

- [`Pytest`](https://docs.pytest.org/en/7.0.1/): one of the most known Python testing framework. I included a basic test suite in the template, which you can expand as needed.

- [`Loguru`](https://black.vercel.app/): this might seem an unconventional choice, but I included this logging library because I use it in most of my projects and find it convenient to have it pre-configured.

## Infrastructure

The template also comes with some infrastructure and CI/CD tools:

- [`Pre-commit`](https://pre-commit.com/): I didn't know about this framework when I first created the template, but it was recommended in a Reddit comment, so I decided to integrate it. It allows you to manage your pre-commit hooks in a simple and unified way. The current configuration is very basic (it only runs the formatter), but you can easily expand it.

- [`Github Actions`](https://github.com/GiovanniGiacometti/python-repo-template/blob/main/.github/workflows/main-lint-test.yaml): the template contains a simple workflow that runs the linter and the tests on every push on the main branch. 

- [`Docker`](https://www.docker.com/): the template comes with a Dockerfile that you can use to build a container. It's inspired by [this example](https://github.com/astral-sh/uv-docker-example/blob/main/multistage.Dockerfile) and uses a multi-stage build that eventually creates a small image containing the source code and the environment, without including uv.

---

> A common question I received was along the lines of: "Why didn’t you include X?" Honestly, I don’t always have a great answer — most likely, I wasn’t aware of X or simply didn’t think it was necessary. However, I’m always open to suggestions, and you probably have a good reason for recommending it.

## Conclusion

I hope you found this blog post and the template useful! If you have any questions or feedback, feel free to write me a message or open an issue on the repository.


