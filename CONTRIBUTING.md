# Contributing Guidelines

Contributions are always welcome; however, please read this document in its entirety before submitting a pull request or reporting a bug.

## Table of Contents

- [Reporting a bug](#reporting-a-bug)
  - [Security disclosure](#security-disclosure)
- [Creating an issue](#creating-an-issue)
- [Opening a pull request](#opening-a-pull-request)
- [License](#license)

---

## Reporting a Bug

Think you've found a bug? Let us know by following the instructions in our [bug reporting guide](https://support.circleci.com/hc/en-us/articles/360054033532-How-can-I-report-a-bug).

### Security Disclosure

Security is a top priority for us. If you have encountered a security issue, please responsibly disclose it by following our [security disclosure](https://circleci.com/docs/2.0/security/) document.

## Creating an Issue

Your issue must follow these guidelines for it to be considered:

### Before Submitting

- Check you’re on the latest version, we may have already fixed your bug!
- [Search our issue tracker](https://github.com/circleci-public/circleci-server-monitoring-reference/issues/search&type=issues) for your problem, someone may have already reported it.

## Opening a Pull Request

To contribute, [fork](https://help.github.com/articles/fork-a-repo/) `circleci-server-monitoring-reference`, commit your changes, and [open a pull request](https://help.github.com/articles/using-pull-requests/).

Your request will be reviewed as soon as possible. You may be asked to make changes to your submission during the review process.

### Before Submitting

- Test your change thoroughly. Deploy it to your own CircleCI server environment to ensure it works as expected. You can find instructions on how to deploy in the [Installing the Monitoring Stack](https://github.com/CircleCI-Public/circleci-server-monitoring-reference?tab=readme-ov-file#installing-the-monitoring-stack) section of our README.
- Utilize the `./do` script to assist in your testing workflow. Here are some examples of how you can use it:
  ```bash
  # Run the Helm unit tests
  ./do unit-tests

  # Lint the dashboards
  ./do lint-dashboards

  # See a full list of available options
  ./do help
  ```
- If updating or modifying a Grafana dashboard, ensure to follow the instructions in the [README](https://github.com/circleci-public/circleci-server-monitoring-reference?tab=readme-ov-file#modifying-or-adding-grafana-dashboards).

## License

CircleCI's `circleci-server-monitoring-reference` is released under the [Apache 2.0 License](./LICENSE).
