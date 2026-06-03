# stacknova-infra

Environnement de recette pour l'équipe QA de StackNova.

Ce projet automatise le déploiement d'un environnement de recette reproductible avec Terraform et Ansible. Terraform provisionne un conteneur Nginx, puis Ansible le configure en déposant une page personnalisée et en vérifiant que le service HTTP répond correctement.

## Prérequis

| Outil | Commande de vérification | Version utilisée |
|---|---|---|
| Docker | `docker --version` | `29.5.2` |
| Terraform | `terraform version` | `v1.15.5` |
| Ansible | `ansible --version` | `core 2.16.3` |

Collection Ansible requise :

```bash
ansible-galaxy collection install community.docker
```

Cette collection est installée automatiquement par `scripts/deploy.sh`.

## Déploiement

Le déploiement complet se lance avec une seule commande :

```bash
bash scripts/deploy.sh
```

Ce script enchaîne automatiquement `terraform init`, `terraform apply` puis l'exécution du playbook Ansible, conformément à la consigne de déploiement en une seule commande.

L'application est ensuite accessible à l'adresse suivante :

```text
http://localhost:8080
```

## Reproductibilité

L'environnement peut être détruit puis reconstruit à l'identique avec les commandes suivantes :

```bash
terraform -chdir=terraform destroy
bash scripts/deploy.sh
```

La version du provider Docker est épinglée en `4.4.0` et verrouillée via `.terraform.lock.hcl`, tandis que l'image Nginx est épinglée en `nginx:1.30.2`. Cela garantit un résultat stable dans le temps ; seul l'horodatage affiché dans la page varie à chaque exécution.

## Questions théoriques

### Q1 — Différence entre Terraform et Ansible

Terraform sert à provisionner l'infrastructure, c'est-à-dire à créer les ressources définies dans le code. Dans ce projet, il crée l'image Docker, le conteneur `stacknova-recette`, l'exposition de port et les labels. Ansible intervient ensuite pour configurer le contenu du conteneur, en déposant la page HTML personnalisée et en vérifiant que Nginx répond. Les deux outils sont donc complémentaires.

### Q2 — Rôle du state file Terraform

Le fichier `terraform.tfstate` conserve le lien entre les ressources déclarées dans le code et les ressources réellement créées, par exemple les identifiants Docker. Il permet à Terraform de savoir quoi créer, modifier ou détruire. En équipe, une mauvaise gestion du state peut provoquer des incohérences, des conflits ou des suppressions involontaires de ressources.

### Q3 — Idempotence

Une opération est dite idempotente lorsque son exécution répétée conduit au même état final qu'une seule exécution. Dans ce projet, un nouveau `terraform apply` ne recrée pas le conteneur s'il est déjà conforme à l'état attendu. En revanche, la tâche `raw` qui régénère la page HTML n'est pas strictement idempotente, car l'horodatage change à chaque exécution.

### Q4 — Différence entre `terraform apply` et `terraform apply -replace`

`terraform apply` applique uniquement les changements détectés entre la configuration et l'état courant. `terraform apply -replace=ADRESSE` force la destruction puis la recréation d'une ressource précise, même si Terraform ne détecte pas de dérive. Cette option est utile lorsqu'une ressource existe encore dans le state mais qu'elle est corrompue ou incohérente côté runtime.

### Q5 — Pourquoi éviter `latest`

Le tag `latest` n'est pas figé et peut pointer vers des images différentes selon la date du déploiement. Deux exécutions identiques peuvent donc produire des résultats différents, ce qui nuit à la reproductibilité et au diagnostic des incidents. C'est pour cette raison que le sujet impose une version d'image explicitement épinglée.
