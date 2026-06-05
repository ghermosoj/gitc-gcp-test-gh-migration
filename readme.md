This is for the test and it serves as a reminder that I need to push the function code to the toolbox

One important thing is that in GitHub we can change the default settings of the branch (At first point it is 'main' while in bitbucket it is 'master') so in order to let everything triggered or based on the same name after the migration, we can set the configuration of the GitHub organization to have the default branch named as 'master'

For testing the pub/sub trigger, we can update/send a message in the topic that the trigger is suscribed to with the next command:
gcloud pubsub topics publish test-github-topic     --project="vwgitc-pipeline-1616076174"     --message="pub/sub message for the pub/sub pipeline"