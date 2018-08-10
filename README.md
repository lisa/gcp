# lisa/gcp

This is a sick day project to try and keep my mind active. The goals are going to try and use a minimal [Python Docker container](https://github.com/lisa/docker-sample-static-python) to do some cool stuff in GCP with the GKE product. For folks creeping on this, do not expect much polish or elegance since this repository is a learning opportunity!

# Top Level Goals

* Use Terraform to provision GCP components:
 * ~~Networking~~
  * ~~Firewalls~~ (default deny on instances w/ Ingress being a 'hole')
  * ~~Load balancers~~ (Ingress)
 * ~~Build system~~
  * ~~Bake the Docker image (from this repo's source, I guess) to GCR~~
 * ~~Deploy the image to GKE?~~
* ~~Do something more interesting with the static Python container (maybe it'll generate random numbers based off user input?)~~
