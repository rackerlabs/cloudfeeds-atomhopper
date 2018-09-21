node('java') {
   def mvnHome
   stage('Preparation') { // for display purposes
      // Get some code from a GitHub repository
      git 'https://github.com/rackerlabs/cloudfeeds-atomhopper.git'
      // Get the Maven tool.
      // ** NOTE: This 'M3' Maven tool must be configured
      // **       in the global configuration.           
      // mvnHome = tool 'M3'
   }
   stage('Builds') {
      // Run the maven build
     // sh "'${mvnHome}/bin/mvn' clean install" 
      sh "mvn clean install" 
   }
   stage('Results') {
      archiveArtifacts artifacts: "filters/*/target/*.jar"
      slackSend channel: "@teja.cheruku", color: "#FC05DE", message: "Deployed branch"
   }
}
