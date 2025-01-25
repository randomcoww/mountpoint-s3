### Container for AWS mountpoint-S3

https://github.com/awslabs/mountpoint-s3

Latest release

```bash
curl -s https://api.github.com/repos/awslabs/mountpoint-s3/releases/latest |grep tag_name | cut -d '"' -f 4 | tr -d 'mountpoint\-s3\-'
```

Tag latest by date

```bash
TAG=v$(date -u +'%Y%m%d').1
git tag -a $TAG
git push origin $TAG
```