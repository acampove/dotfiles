## classd
```python
# ----------------------
class {1}:
    '''
    {2}
    '''
    # ----------------------
    def __init__(self, {3}):
        '''
        Parameters
        -------------
        {4}
        '''
        {5}
```

## deftt
```python
# ----------------------
def {1}({2}) -> {3}:
    '''
    {4}

    Parameters 
    -------------
    {5}
    '''
    {6}
```

## pargs
```python
import argparse

# ----------------------
def _parse_args() -> None:
    parser = argparse.ArgumentParser(description='{1}')
    parser.add_argument('{2}', '{3}' , type=str, help='{4}')
    args = parser.parse_args()
```

## data_class
```python
# ----------------------
class Data:
    '''
    Class meant to be used to share attributes
    '''
    {1}
```

## logger
```python
from dmu.logging.log_store import LogStore

log=LogStore.add_logger('{1}')
# ----------------------
{2}
```

## main
```python
# ----------------------
def main():
    '''
    Entry point
    '''
    {1}
# ----------------------
if __name__ == '__main__':
    main()
```

## deftd
```python
# ----------------------
def {1}({2}) -> {3}:
    '''
    Parameters
    -------------
    {4}

    Returns
    -------------
    {5}
    '''
    {6}
```

## test_initializer
```python
# ----------------------
@pytest.fixture(scope='session', autouse=True)
def initialize():
    '''
    This will run before any test
    '''
    {1}
```

