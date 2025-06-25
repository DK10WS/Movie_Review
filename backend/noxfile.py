import nox


@nox.session
def lint(session):
    session.run(
        "uv",
        "sync",
        "--active",
        "--locked",
        "--inexact",
        external=True,
    )

    session.run("pyrefly", "check", "src/", external=True)
    session.run("ruff", "format", external=True)
    session.run("ruff", "check", external=True)
