// 🔧 Unified Jenkins Job DSL Script: Environments + Multibranch Pipelines + Utilities + Shared Libraries
// Purpose: Fully automated Jenkins job creation for different environments and applications (Java/.NET)

// ----------- ENVIRONMENT-SPECIFIC FOLDERS AND CONFIGURATION JOB -----------
folder('environments') {
    displayName('Environments')
    description('Environment-specific configurations')
}

folder('environments/dev') {
    displayName('Development')
    description('Development environment configuration')
}

folder('environments/test') {
    displayName('Test')
    description('Test environment configuration')
}


// 🔁 Manual environment selection and configuration job (adjusts retention, registry, etc.)
pipelineJob('environments/configure-environment') {
    displayName('Configure Environment')
    description('Configure Jenkins for the current environment')
    parameters {
        choiceParam('ENVIRONMENT', ['dev', 'test', 'prod'], 'Select the environment to configure')
    }
    definition {
        cps {
            script('''
                pipeline {
                    agent {
                        label 'java'
                    }
                    stages {
                        stage('Configure Environment') {
                            steps {
                                script {
                                    echo "Configuring Jenkins for ${params.ENVIRONMENT} environment"
                                    if (params.ENVIRONMENT == 'dev') {
                                        env.DOCKER_REGISTRY = 'dev-registry.example.com'
                                        env.BUILD_RETENTION_DAYS = '3'
                                    } else if (params.ENVIRONMENT == 'test') {
                                        env.DOCKER_REGISTRY = 'test-registry.example.com'
                                        env.BUILD_RETENTION_DAYS = '7'
                                    } else {
                                        env.DOCKER_REGISTRY = 'docker.io'
                                        env.BUILD_RETENTION_DAYS = '30'
                                    }
                                    echo "Using Docker registry: ${env.DOCKER_REGISTRY}"
                                    echo "Build retention set to: ${env.BUILD_RETENTION_DAYS} days"
                                }
                            }
                        }
                    }
                }
            ''')
            sandbox(true)
        }
    }
}

// ----------- APPLICATION PIPELINES FOR JAVA AND .NET -----------
// 🧬 Project metadata for each pipeline (name, repo, agent, docker image, etc.)
def projects = [
    [
        name: 'java-sample-app',
        displayName: 'Java Sample Application',
        description: 'CI/CD pipeline for the Java sample application',
        repoUrl: 'git@github.com:WahbaMousa-DevOps/DevOps-Stack-Test-Repo-Java.git',
        type: 'java',
        branch: 'main',
        agentLabel: 'java',
        dockerRegistry: 'docker.io',
        dockerImageName: 'wahbamousa/java-sample-app'
    ],
    [
        name: 'csharp-sample-app',
        displayName: 'C# Sample Application',
        description: 'CI/CD pipeline for the C# sample application',
        repoUrl: 'git@github.com:WahbaMousa-DevOps/DevOps-Stack-Test-Repo-C-sharp.git',
        type: 'dotnet',
        branch: 'main',
        agentLabel: 'dotnet',
        dockerRegistry: 'docker.io',
        dockerImageName: 'wahbamousa/csharp-sample-app'
    ],
    [
    name: 'nodejs-sample-app',
    displayName: 'Node.js Sample Application',
    description: 'CI/CD pipeline for the Node.js sample application',
    repoUrl: 'git@github.com:WahbaMousa-DevOps/DevOps-Stack-Test-Repo-Nodejs.git',
    type: 'nodejs',
    branch: 'main',
    agentLabel: 'nodejs',
    dockerRegistry: 'docker.io',
    dockerImageName: 'wahbamousa/nodejs-sample-app'
]

]

// 📁 Folder hierarchy for applications and pipeline grouping
folder('applications') {
    displayName('Application Pipelines')
    description('CI/CD pipelines for all applications')
}

folder('applications/java') {
    displayName('Java Applications')
    description('Java application pipelines')
}

folder('applications/dotnet') {
    displayName('.NET Applications')
    description('.NET application pipelines')
}

folder('applications/nodejs') {
    displayName('Node.js Applications')
    description('Node.js application pipelines')
}


projects.each { project ->
      def parentFolder = "applications/${project.type}"
   // def parentFolder = "applications/${project.type == 'java' ? 'java' : 'dotnet'}"

    // 🔁 Automatically scan and create multibranch pipelines from GitHub
    multibranchPipelineJob("${parentFolder}/${project.name}") {
        displayName(project.displayName)
        description(project.description)
        branchSources {
            git {
                id("${project.name}-source")
                remote(project.repoUrl)
                credentialsId('github-ssh-key') // 🔐 SSH authentication with GitHub
                traits {
                    branchDiscoveryTrait { strategyId(3) } // 🔎 Discover all branches
                    pruneStaleBranchTrait()
                    cleanBeforeCheckoutTrait()
                    localBranchTrait()
                }
            }
        }
        triggers {
            periodicFolderTrigger { interval('1h') } // 🔄 Re-scan GitHub every hour
        }
        orphanedItemStrategy {
            discardOldItems {
                daysToKeep(7)
                numToKeep(10)
            }
        }
        properties {
            folderProperties {
                properties {
                    stringProperty { key('projectType'); value(project.type) }
                    stringProperty { key('dockerImageName'); value(project.dockerImageName) }
                    stringProperty { key('agentLabel'); value(project.agentLabel) }
                }
            }
        }
    }
}

// ----------- SHARED LIBRARIES AND UTILITIES -----------
// 📚 Shared libraries folder to register reusable Jenkins pipelines
folder('shared-libraries') {
    displayName('Shared Libraries')
    description('Pipeline shared libraries')
}

pipelineJob('shared-libraries/configure-libraries') {
    displayName('Configure Global Libraries')
    description('Job to configure global shared libraries')
    definition {
        cps {
            script('''
                pipeline {
                    agent { label 'java' }
                    stages {
                        stage('Configure Libraries') {
                            steps {
                                echo "Configuring global shared libraries"
                            }
                        }
                    }
                }
            ''')
            sandbox(true)
        }
    }
}

// 🧰 Utility folder and cleanup job for workspace and Docker cache
folder('utilities') {
    displayName('Utility Jobs')
    description('Utility and maintenance jobs')
}

pipelineJob('utilities/clean-workspaces') {
    displayName('Clean Workspaces')
    description('Job to clean workspaces on all agents')
    definition {
        cps {
            script('''
                pipeline {
                    agent none
                    stages {
                        stage('Clean Java Agent') {
                            agent { label 'java' }
                            steps {
                                cleanWs()
                                sh 'docker system prune -af'
                            }
                        }
                        stage('Clean Dotnet Agent') {
                            agent { label 'dotnet' }
                            steps {
                                cleanWs()
                                sh 'docker system prune -af'
                            }
                        }
                        stage('Clean Node.js Agent') {
                            agent { label 'nodejs' }
                            steps {
                                cleanWs()
                                sh 'docker system prune -af'
                            }
                        }

                    }
                }
            ''')
            sandbox(true)
        }
    }
} // End
