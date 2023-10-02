Contributing to this repo
=========================

# pre-commit hooks

To ensure common formatting and validations, please install pre-commit in your clone.

## 1. Install pre-commit 

Mac:

```
brew install pre-commit tflint
```

Linux:

```
pip install pre-commit
sudo curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && sudo mv tflint /usr/local/bin/
```

## 2. Install pre-commit in this repo

```
pre-commit install -t pre-commit
```
