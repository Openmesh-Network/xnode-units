## Xnode Units

The Xnode Unit (XU) ERC721 token and related contracts.  

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
forge build
```

### Test

```shell
forge test
```

### Deploy

```shell
make deploy
```

## Local chain

```shell
anvil
make local-fund ADDRESS="YOURADDRESSHERE"
```

### Analyze

```shell
make slither
make mythril TARGET=Counter.sol
```

### Help

```shell
forge --help
anvil --help
cast --help
```
