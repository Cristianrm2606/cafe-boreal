
#!/bin/bash
kubectl exec -it -n cafe-boreal deployment/postgres -- psql -U postgres -d cafeboreal
