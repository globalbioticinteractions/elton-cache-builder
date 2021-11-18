# elton-cache-builder

Prepares elton datasets for publication on Zenodo. 

# Prequisites

 * make
 * java 8+
 * curl
 * internet connection
 * Zenodo access token
 * unpublished Zenodo deposit id
 
# Usage

Run:
```
make ELTON_PACKAGE=[some elton package name] ZENODO_DEPOSIT=[some unpublished zenodo deposit id] 
```

example:

```
make ELTON_PACKAGE=globalbioticinteractions/msb-para ZENODO_DEPOSIT=5711446
```

