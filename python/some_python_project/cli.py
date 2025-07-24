import argparse

def run():
    parser = argparse.ArgumentParser(
        prog="ProgramName",
        description="Some Python App",
    )

    # https://docs.python.org/3/library/argparse.html
    parser.add_argument('-v', '--verbose', action='store_true')

    args = parser.parse_args()
    print(f"{args}")
