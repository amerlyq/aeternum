print(f'#4 file={__file__} pkg={__package__} nm={__name__}')

from ..main import __appname__
from ..cfg import var

def main():
    print(f'{__appname__}: [main()] var={var}')
