def getEnvForSuite(suiteName, pythonVersion) {
  // Base environment variables
  def envVars = [
    "TEST_SUITE=${suiteName}",
    "PYTHON_VERSION=${pythonVersion}",
    'DOCKER_HOST=',
    "CLOUDANT_ACCOUNT=$DB_USER",
    "RUN_CLOUDANT_TESTS=1",
    "SKIP_DB_UPDATES=1" // Disable pending resolution of case 71610
  ]
  // Add test suite specific environment variables
  switch(suiteName) {
    case 'basic':
      envVars.add("RUN_BASIC_AUTH_TESTS=1")
      break
    case 'iam':
      // Setting IAM_API_KEY forces tests to run using an IAM enabled client.
      envVars.add("IAM_API_KEY=$DB_IAM_API_KEY")
      break
    case 'cookie':
    case 'simplejson':
      break
    default:
      error("Unknown test suite environment ${suiteName}")
  }
  return envVars
}

def setupPythonAndTest(pythonVersion, testSuite) {
  node {
    // Unstash the source on this node
    unstash name: 'source'
    // Set up the environment and test
    withCredentials([usernamePassword(credentialsId: 'clientlibs-test', usernameVariable: 'DB_USER', passwordVariable: 'DB_PASSWORD'),
                     string(credentialsId: 'clientlibs-test-iam', variable: 'DB_IAM_API_KEY')]) {
      withEnv(getEnvForSuite("${testSuite}", "${pythonVersion}")) {
        try {
          try {
              sh "docker-compose -f nosetests.yml -f cloudant-service.yml up --abort-on-container-exit"
          } finally {
              sh "docker-compose -f nosetests.yml -f cloudant-service.yml down -v --rmi local"
          }
        } finally {
          // Load the test results
          junit 'output/nosetests.xml'
        }
      }
    }
  }
}

// Start of build
stage('Checkout'){
  // Checkout and stash the source
  node{
    checkout scm
    stash name: 'source'
  }
}

stage('Test'){
  def py3 = 'latest'
  def axes = [:]
  ['2.7', py3].each { version ->
    ['basic','cookie','iam'].each { auth ->
       axes.put("Python${version}-${auth}", {setupPythonAndTest(version, auth)})
    }
  }
  axes.put("Python${py3}-simplejson", {setupPythonAndTest(py3, 'simplejson')})
  parallel(axes)
}

stage('Publish') {
  gitTagAndPublish {
    isDraft=true
    releaseApiUrl='https://api.github.com/repos/cloudant/python-cloudant/releases'
  }
}
