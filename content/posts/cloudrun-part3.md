---
date: 2024-11-06
# description: ""
# image: ""
lastmod: 2024-11-06
showTableOfContents: false
tags: ["GCP","Github Actions", "CI/CD"]
title: "Part 3: Oops, Something Went Wrong! Let’s Roll Back to the Rescue "
type: "post"
draft: false
---

### Part 3: Oops, Something Went Wrong! Let’s Roll Back to the Rescue

In this section, we’ll cover the steps that help ensure the stability of your Cloud Run deployment by implementing an automatic rollback mechanism in case of failure. Even the most carefully planned deployments can encounter issues, and it's essential to have a strategy in place to quickly revert to a stable version of your application.

We’ll walk through how to use GitHub Actions to automatically detect failed deployments, list the service revisions, and roll back to the most recent working version. This ensures your service remains reliable and minimizes any downtime caused by deployment issues.

Let's dive into the key steps that handle failure detection and the rollback process effectively in a Cloud Run environment.

### **Rollback Mechanism on Failure**

#### 11. **List Revisions**

This step lists all the revisions of the Cloud Run service. It first checks for the active revision, then assigns the rollback target based on whether the active revision exists or not.

```yaml
- name: List Revisions
  id: list-revisions
  if: failure()
  run: |
    # Fetch the list of revisions and their status (active or not)
    REVISIONS=$(gcloud run revisions list --service=$CLOUD_RUN_SERVICE_NAME --region=$ARTIFACT_REGION --format="value(REVISION,ACTIVE)") 
    ACTIVE_REVISION=""
    PREVIOUS_REVISION=""

    # Process the list of revisions to identify the active and previous revision
    while read -r REVISION ACTIVE; do
      if [ "$ACTIVE" = "yes" ]; then
        ACTIVE_REVISION="$REVISION"
      elif [ -z "$PREVIOUS_REVISION" ]; then
        PREVIOUS_REVISION="$REVISION"
      fi
    done <<< "$REVISIONS"

    # Determine the rollback revision (either active or previous)
    if [ -n "$ACTIVE_REVISION" ]; then
      ROLLBACK_REVISION="$ACTIVE_REVISION"
    else
      ROLLBACK_REVISION="$PREVIOUS_REVISION"
    fi

    # Output the revision that will be rolled back to
    echo "Rollback target revision: $ROLLBACK_REVISION"
    echo "::set-output name=previous-revision::$ROLLBACK_REVISION"` 
```

##### **Explanation of this Step:**

-   The `gcloud run revisions list` command is used to fetch a list of all revisions for the specified Cloud Run service.
-   The script processes the list to find the active revision (which is the latest deployed version) and the previous revision.
-   It checks if there is an active revision and, if so, sets it as the target for rollback. If no active revision is found, it defaults to the previous one.
-   The revision that will be used for rollback is then saved and made available to the next step using the `set-output` command.

----------

#### 12. **Rollback to Previous Version**

If the deployment fails, this step rolls back the Cloud Run service to the previous or active revision identified in the previous step.

```yaml
- name: Rollback to Previous Version
  if: failure()
  run: |
    # Rollback to the previous revision identified in the previous step
    gcloud run services update-traffic $CLOUD_RUN_SERVICE_NAME --region=$ARTIFACT_REGION --to-revisions ${{ steps.list-revisions.outputs.previous-revision }}=100` 
```

##### **Explanation of this Step:**

-   This step uses the `gcloud run services update-traffic` command to roll back the Cloud Run service to the revision identified in the previous step (`$steps.list-revisions.outputs.previous-revision`).
-   The `=100` flag ensures that 100% of the traffic is routed to the previous revision, effectively rolling back the service to the previous working version.
-   The rollback action ensures that, in case of failure, the service can be restored to a stable state, minimizing downtime.

### Conlusion

Further delved into the importance of ensuring your Cloud Run deployments are reliable, even when things go wrong. We explored how to implement an automatic rollback mechanism using GitHub Actions. If a deployment fails, the pipeline automatically detects the issue, lists the service revisions, and rolls back to the last known stable version of the application.

This rollback strategy is key to maintaining high availability and minimizing downtime. With these steps in place, you can rest assured that your deployment pipeline is not only efficient but also resilient, capable of recovering from failures and ensuring that your service remains operational even during challenging circumstances.