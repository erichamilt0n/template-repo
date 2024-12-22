# Contributing Guidelines

Thank you for your interest in contributing to this project! This document provides guidelines and steps for contributing.

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct. Please read it before contributing.

## How to Contribute

1. **Fork the Repository**
   - Fork the repository to your GitHub account
   - Clone your fork locally

2. **Create a Branch**
   - Create a branch for your changes
   - Use a descriptive name (e.g., `feature/add-new-endpoint`, `fix/login-issue`)

3. **Make Your Changes**
   - Follow the coding style and conventions
   - Write clear, descriptive commit messages
   - Include tests for new features
   - Update documentation as needed

4. **Test Your Changes**
   - Run the test suite: `npm test`
   - Run linting: `npm run lint`
   - Ensure all checks pass

5. **Submit a Pull Request**
   - Push your changes to your fork
   - Create a pull request to our main branch
   - Fill out the pull request template completely
   - Link any relevant issues

## Development Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Set up pre-commit hooks:
   ```bash
   npm run prepare
   ```

3. Create a `.env` file based on `.env.example`

## Coding Standards

- Follow ESLint and Prettier configurations
- Write self-documenting code
- Include JSDoc comments for functions
- Keep functions small and focused
- Write meaningful variable and function names

## Testing Guidelines

- Write unit tests for new features
- Maintain or improve code coverage
- Test edge cases and error conditions
- Use meaningful test descriptions

## Documentation

- Update README.md for significant changes
- Document new features and APIs
- Include examples where appropriate
- Keep documentation up to date

## Review Process

1. All submissions require review
2. Changes must pass CI/CD checks
3. Reviews require at least one approval
4. Address review feedback promptly

## Additional Resources

- [Issue Templates](.github/ISSUE_TEMPLATE/)
- [Pull Request Template](.github/PULL_REQUEST_TEMPLATE.md)
- [Security Policy](SECURITY.md)

## Questions?

Feel free to create an issue for any questions about contributing.
