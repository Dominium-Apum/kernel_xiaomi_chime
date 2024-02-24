# _hanikrnl._

A customised Linux 4.19 fork tailored towards Android devices, specifically POCO M3 & Redmi 9T and derivatives.


## Branches

The branches on this project are made use of just like any other project but there are some details you might have to keep in mind if you are a **device maintainer** or are looking to contribute!

- `main`/Default branch - The one that receives constant changes and force pushes, keep in mind that the patches that go here are not promised to stable and are always subject to removal.

- `android` - The comparitively slower rolling branch, the changes that make the cut drop down here. This branch also adds a patch for [KernelSU](https://github.com/tiann/KernelSU), this is omitted from the main branch to avoid build issues for predictability reasons. Few experimental compiler optimizations are also missing here compared to `main` to retain compatibility with AOSP Clang.

- `The rest of the branches` - They're just there for me to segregate and test/experiment with different patchsets, they shouldn't mean much to you unless if you feel curious.


## Building

This project comes equipped with a build workflow that makes use of Github Actions.

- Fork the repository. You may want to clone all the branches, uncheck the box in the fork menu to do so.

- After the fork is made you'll be redirected to the repo in your own namespace. Navigate to the "Actions" tab.

- Select "Build Kernel on GitHub Actions" and you can run the workflow from this menu. Choose the branch you wany to build from, the default selection will be the default branch.
> ⚠️ **If unsure about what branch you would like to build please visit the [Branches](https://github.com/Dominium-Apum/kernel_xiaomi_chime/tree/android#branches) section.**

- Once you start the workflow you'll have to wait until it goes through, you can visually track the progress of the build if you navigate into the build section of the workflow.

- After the build finishes you'll be presented with a zip file in the Artifacts section of your respective run.
> ⚠️ **BEFORE YOU FLASH:** The artifact that gets spit out by your run isn't flashable on a device yet! The .zip file on Github is infact a nested zip and has the actual flashable .zip file inside itself. This is a limitation from [upload-artifact](https://github.com/actions/upload-artifact]) and is not something I can do much about.

## Building alongside AOSP
If you would like to build this alongside AOSP you may choose to do so, the appropriate branch for cloning is `android` for more information visit the [Branches](https://github.com/Dominium-Apum/kernel_xiaomi_chime/tree/android#branches) section.

## Contributing

Contributions are always welcome, just be aware that we don't really do tags on this project and is very much rolling release!

Pull Requests can be sent to this repository directly and they may be merged after a review.



## Acknowledgements

 - [Anya Kernel](https://github.com/frstprjkt/kernel_xiaomi_chime-anya) - The project this kernel was originally forked from, since then we have significantly diverged in terms of scope and direction.

 - The various kernel hackers from the Android and the larger Linux community, alot of the contributions made here are a derivative of their work.


---


Linux kernel
============

There are several guides for kernel developers and users. These guides can
be rendered in a number of formats, like HTML and PDF. Please read
Documentation/admin-guide/README.rst first.

In order to build the documentation, use ``make htmldocs`` or
``make pdfdocs``.  The formatted documentation can also be read online at:

    https://www.kernel.org/doc/html/latest/

There are various text files in the Documentation/ subdirectory,
several of them using the Restructured Text markup notation.
See Documentation/00-INDEX for a list of what is contained in each file.

Please read the Documentation/process/changes.rst file, as it contains the
requirements for building and running the kernel, and information about
the problems which may result by upgrading your kernel.
