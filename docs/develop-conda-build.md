# setup a development environment to hack on `conda-build`

1. Clone [conda-build](https://github.com/conda/conda-build) and test repository

    ```
    git clone git@github.com:jdblischak/conda-build.git
    git clone git@github.com:conda/conda_build_test_recipe.git
    cd conda-build
    git remote add upstream git@github.com:conda/conda-build.git
    ```

1. Create environment for development

    ```
    mamba create -n dev-cb --file tests/requirements.txt
    conda activate dev-cb
    ```

1. Install local version of conda-build

    ```
    pip install --no-deps --editable .
    ```

1. Confirm installation

    ```
    # Should see the development version
    conda-build --version

    # Due to the "magic" of the conda command, this finds the
    # `conda-build` installed in the base environment. Make
    # sure you always call `conda-build` directly. You would
    # have to install the dev version in your base environment
    # for `conda build` to invoke the dev version
    conda build --version
    ```

1. Run the tests. The entire test suite is unbearably slow. You can obtain
   quicker feedback by specifying one of the test files for the CRAN skeleton,
   or even better the exact test function

    ```
    # Unit tests for individual functions defined in the CRAN skeleton
    pytest tests/test_cran_skeleton.py
    # Integrative tests that simulate calling `conda skeleton cran`
    pytest tests/test_api_skeleton_cran.py
    # Example of how to specify the exact test within a test file
    pytest tests/test_api_skeleton_cran.py::test_cran_no_comments
    ```

1. Install and run flake8

    ```
    mamba install flake8
    flake8 path/to/file
    ```

Sources:

* [Contributing](https://github.com/conda/conda-build#contributing)
* [Testing](https://github.com/conda/conda-build#development-environment)
* [pytest > py.test](https://stackoverflow.com/questions/39495429/py-test-vs-pytest-command)
