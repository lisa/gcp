require 'rake'
require 'optparse'
require 'json'
require 'yaml'

load "src/Rakefile"

CONFIG_FILE = File.join(File.dirname(__FILE__),"terraform","gcp.tfvars")
SERVICE_ACCOUNT_CREDENTIALS_FILE = File.join(File.dirname(__FILE__), "terraform", "account.json")
HELM_VALUES_FILE = File.join(File.dirname(__FILE__),"randomapp","values.yaml")

# Read config from gcp.tfvars file (it's JSON, surprise)
CONFIG = (JSON.parse(File.read(CONFIG_FILE))) rescue {}

#validate config has the stuff we need
[ 'gcp_region' ].each do |key|
  fail "Aborting: Need '#{key}' in #{CONFIG_FILE}" unless CONFIG.keys.include?(key)
end

def validate_config(key)
#  puts "got #{key}? => #{CONFIG.inspect} -> #{CONFIG.keys.include?(key)}"
  CONFIG.keys.include?(key)
end

namespace :config do
  desc "Print Config"
  task :print_config do
    CONFIG.keys.sort.each do |key|
      puts "#{key} = #{CONFIG[key]}"
    end
  end
  
  desc "Explain config keys"
  task :explain_config do
    puts <<~EXPLAIN_KEYS   
    app_image_name         : Used in GCR to identify the test app (do not change)
    gcp_region             : GCP Region to operate in (change this)
    gcp_zone               : Which GCP zone to run in (change this)
    gcr_hostname           : Geolocation region for GCR (optional change)
    gke_node_count         : How many nodes to create in GKE cluster (optional change)
    gke_node_disk_size     : Disk size for GKE nodes in GB (optional change)
    gke_node_type          : GCE node machine type for GKE cluster member nodes (optional change)
    google_billing_account : The alphanumeric ID of the billing account this project belongs to.  (change this after step 6)
    google_project_name    : Human-readable GKE project name. Largely unused. (change this)
    project_id             : Google-assigned project ID (change this)
    
    Prior to beginning, the user must pre-populate these:
    * gcp_region
    * gcp_zone
    * gcr_hostname
    * gke_node_count
    * gke_node_disk_size
    * gke_node_type
    * google_project_name
    * google_billing_account
    
    After step 4, the user must populate:
    * project_id
    EXPLAIN_KEYS
  end
end

task :default => ["bootstrap:help"]
namespace :bootstrap do
  desc "Print help"
  task :help do
    puts <<~HELP
    Bootstrap steps:
    1. Sign up for Google Cloud Platform
    2. Download gcloud and terraform and helm
    3. gcloud auth login
    4. Create a GCP project in the GCP console or with gcloud
    5. gcloud config set project <name of your project>
    6. Set up billing
    7. Create a service account with appropriate roles and download credentials as ./terraform/account.json
    8. Enable GCP API access for the service account.
    9. Apply Terraform
    10. Set up Kubernetes gcloud container clusters get-credentials YOURCLUSTERNAME --region YOURREGION  
    11. Provision Helm service account
    12. Update Helm values.yaml file with project-specific data
    13. Configure Docker to push to GCR
    14. Build and push the app from ../src to GCR:
    15. Deploy with Helm
    16. Verify it worked
    HELP
  end
  
  desc "1 Signup"
  task :signup do
    puts <<~SIGNUP
    Sign up for GCP at https://cloud.google.com
    SIGNUP
    true
  end
  
  desc "2a Install gcloud tool and terraform (Linux and MacOS)"
  task :install_gcloud do
    found = ENV['PATH'].split(':').select { |d| File.exist?(File.join(d,'gcloud')) }.size
    unless found
      puts <<~INSTALL_GCLOUD
      # Run: 
      curl https://sdk.cloud.google.com | bash
      exec -l \$SHELL
      gcloud init --disable-prompts
      INSTALL_GCLOUD
    end
    true
  end
  
  desc "2b Install terraform"
  task :install_terraform do
    found = ENV['PATH'].split(':').select { |d| File.exist?(File.join(d,'terraform')) }.size
    unless found
      puts <<~TERRAFORM
      Download and install Terraform from:
      https://www.terraform.io/intro/getting-started/install.html
      TERRAFORM
    end
    true
  end
  
  desc "2c Install Helm (locally)"
  task :install_helm do
    found = ENV['PATH'].split(':').select { |d| File.exist?(File.join(d,'helm')) }.size
    unless found
      puts <<~INSTALL_HELM
      # Download and install Helm.
      # Homebrew and Chocolatey users:
      brew install kubernetes-helm
      
      # GoFish users:
      gofish install helm (be mindful of pre-releases)
      
      # Binary installs from https://github.com/helm/helm/releases/
      INSTALL_HELM
    end
    true
    
  end
  
  desc "3 Authenticate with gcloud"
  task :gcloud_login => ["bootstrap:install_gcloud"] do
    logged_in_count = `gcloud auth list --filter=status:ACTIVE --format="value(account)" | wc -l`.strip.to_i
    if logged_in_count < 0
      puts <<~GCLOUD_LOGIN
      # Authenticate with 
      gcloud auth login
      GCLOUD_LOGIN
    end
    true
  end
  
  desc "4 Create a GCP Project."
  task :create_project => ["bootstrap:install_gcloud", "bootstrap:gcloud_login"] do
    if ! validate_config('project_id')
      opts = {}
      o = OptionParser.new

      o.banner = "Usage: rake bootstrap:create_project -- --name=<name>"
      o.on('-n',"--name ARG")       { |name|       opts["name"]       = name       }
      o.on('-m',"--human-name ARG") { |human_name| opts["human_name"] = human_name }
      o.on('-r',"--region ARG")     { |region|     opts["region"]     = region     }
      args = o.order!(ARGV) {}
      o.parse!(args)

      fail "Name must match /^[a-z][a-z0-9\\-]{5,29}/" unless (opts['name'] =~ /^[a-z][a-z0-9\-]{5,29}/ rescue false) 
      opts['human_name'] = if CONFIG.keys.include?('google_project_name')
        warn "Using #{CONFIG['google_project_name']} from #{CONFIG_FILE} for human readable project name"
        CONFIG['google_project_name']
      elsif ! opts.keys.include?('human_name')
        warn "No human readable name given on rake commandline, defaulting to #{opts['name']}" 
        opts['name']
      else
        opts['human_name']
      end

      puts <<~CREATE_PROJECT
      # Run
      gcloud projects create --name=#{opts["human_name"]} --enable-cloud-apis #{opts["name"]}
      
      # Once the project is created, add project_id: '#{opts['name']} to #{CONFIG_FILE}
      CREATE_PROJECT
    end
    true
  end
  
  desc "5 Set default project"
  task :set_default_project => ["bootstrap:create_project"] do
    if validate_config('project_id')
      # If there's already a project_id we can check the gcloud config to see if it's our default project and skip this
      default_project = `gcloud config get-value project`.strip
      if CONFIG['project_id'] != default_project
        # set it
        puts <<~SET_PROJ
        # Run:
        gcloud config set project #{CONFIG['project_id']}
        SET_PROJ
      end
    else
      opts = {}
      o = OptionParser.new
    
      o.banner = "Usage: rake bootstrap:set_default_project -- --name=<name>"
      o.on('-n',"--name ARG") { |name| opts["name"] = name }
      args = o.order!(ARGV) {}
      o.parse!(args)

      fail "Name must match /^[a-z][a-z0-9\\-]{5,29}/" unless (opts["name"] =~ /^[a-z][a-z0-9\-]{5,29}/ rescue false) 
      puts "Run:\ngcloud config set project #{opts["name"]}"
      true
    end
  end

  desc "6 Set up billing"
  task :setup_billing do
    puts <<~SETUP_BILLING
    # Set up billing at
    https://console.developers.google.com/project/#{CONFIG['project_id']}/settings
    
    # Then wait a little bit before continuing (Google needs to process it).
    
    # Use `gcloud alpha billing accounts list` to see the ACCOUNT_ID to 
    # which this project is linked, use that to add
    # google_billing_account in #{CONFIG_FILE}
    SETUP_BILLING
  end
  
  # needs project ID
  desc "7 Create service account & save its creds -> ./terraform/account.json"
  task :create_svc_acct => ["bootstrap:create_project","bootstrap:set_default_project"] do
    fail "Need to know project_id (after project creation) in #{CONFIG_FILE}" unless validate_config('project_id')
    unless File.exists?(SERVICE_ACCOUNT_CREDENTIALS_FILE)
      puts <<~CREATE_SVC_ACCT
      gcloud iam service-accounts create terraform --display-name="terraform service account"
      gcloud iam service-accounts keys create --iam-account=terraform@#{CONFIG['project_id']}.iam.gserviceaccount.com #{SERVICE_ACCOUNT_CREDENTIALS_FILE}
      gcloud projects add-iam-policy-binding #{CONFIG['project_id']} --member=serviceAccount:terraform@#{CONFIG['project_id']}.iam.gserviceaccount.com --role=roles/owner
      CREATE_SVC_ACCT
    else
      warn "#{SERVICE_ACCOUNT_CREDENTIALS_FILE} exists. Skipping."
    end
  end
  
  desc "8 Enable APIs for Terraform"
  task :enable_apis do
    puts <<~ENABLE_APIS
    # Run:
    
    gcloud services enable compute.googleapis.com
    gcloud services enable appengine.googleapis.com
    gcloud services enable cloudbilling.googleapis.com
    gcloud services enable iam.googleapis.com
    gcloud services enable container.googleapis.com
    gcloud services enable serviceusage.googleapis.com
    gcloud services enable cloudresourcemanager.googleapis.com
    ENABLE_APIS
    true
  end
  
  desc "9 Apply Terraform"
  task :apply_terraform do
    puts <<~APPLY_TERRAFORM
    # Import the project and Terraformservice account we just made
    terraform import -var-file=#{CONFIG_FILE} google_project.project #{CONFIG['project_id']}
    terraform import -var-file=#{CONFIG_FILE} google_service_account.terraform projects/#{CONFIG['project_id']}/serviceAccounts/terraform@#{CONFIG['project_id']}.iam.gserviceaccount.com
    
    terraform plan -out=my.plan -var-file=gcp.tfvars
    # If it looks okay
    terraform apply "my.plan"
    APPLY_TERRAFORM
    true
  end
  
  desc "10 Get gcloud cluster credentials"
  task :cluster_creds do
    puts <<~CLUSTER_CREDS
    gcloud container clusters get-credentials cluster --region #{CONFIG['gcp_zone']}
    CLUSTER_CREDS
    true
  end
  
  desc "11 Provision Helm service account"
  task :helm_service_acct => [ "bootstrap:install_helm" ] do
    puts <<~HELM_SERVICE_ACCT
    kubectl create serviceaccount --namespace kube-system tiller
    kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
    kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'      
    helm init --service-account tiller --upgrade
    HELM_SERVICE_ACCT
    true
  end
    
  desc "12 Update Helm values.yaml with project-specific values"
  task :update_helm_values do
    [ 'gcr_hostname', 'project_id', 'app_image_name' ].each do |k|
      fail "Need #{k} in #{CONFIG_FILE}" unless validate_config(k)
    end
     
    helm_values = YAML::load_file(HELM_VALUES_FILE)
    helm_values['image']['repository'] = "#{CONFIG['gcr_hostname']}/#{CONFIG['project_id']}/#{CONFIG['app_image_name']}"
    
    # Written like this to preserve comments.
    File.open(HELM_VALUES_FILE,"w") do |f|
      f.write helm_values.to_yaml
    end
    puts "Done."
    true    
  end
  
  desc "13 Configure Docker to push to GCR"
  task :configure_docker_for_gcr => [ "bootstrap:gcloud_login" ] do
    puts <<~CONFIG_DOCKER
    # Run:
    
    gcloud auth configure-docker
    CONFIG_DOCKER
    true
  end
  
  desc "14 Build and push app to GCR"
  task :build_and_push_app => [ "bootstrap:configure_docker_for_gcr" ] do
    Dir.chdir(File.join(File.dirname(__FILE__),"src")) do
      Rake::Task['docker:build:python_app'].execute
      Rake::Task['docker:build:push'].execute
    end
  end
  
  desc "15 Deploy with Helm"
  task :deploy_with_helm do
    puts <<~DEPLOY_WITH_HELM
    # Run:
    
    helm install -n #{CONFIG['app_image_name']} #{File.join(File.dirname(__FILE__),"randomapp")}
    DEPLOY_WITH_HELM
  end
  
  desc "16 Validate it worked"
  task :validate_app do
    require 'net/http'
    state_file = File.join(File.dirname(__FILE__),"terraform","terraform.tfstate")
    tfstate = (JSON.parse(File.read(state_file))) rescue {}
    ip = (tfstate['modules'][0]['outputs']['public_app_ip']['value']) rescue nil
    unless ip.nil?
      puts "Checking (min 10, max 20) from #{ip}..."
      uri = URI("http://#{ip}/?min=10&max=20")
      res = Net::HTTP.get(uri)
      puts res
    else
      puts "Couldn't find the public IP in Terraform state file :("
    end
    true    
  end
  
end