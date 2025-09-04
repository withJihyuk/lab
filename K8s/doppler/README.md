```sh
kubectl create secret generic potato-image-upload \
  --namespace doppler-operator-system \
  --from-literal=serviceToken=
```

## managedSecret

`doppler`에서 만들어주는 secret 값, 원격으로 가져와서 넣어준다.

## tokenSecret

값을 가져오기 위한 키, 복호화를 위해 필요한 거 같다.
