library (RCurl)

#Get Data from UC Irvine ML DB

iris_url="http://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data"
iris_txt=getURL(iris_url)
iris_data=read.csv(textConnection(iris_txt), header=FALSE)

#RENAMING THE COLUMNS
library(plyr)
names(iris_data)
iris=rename(iris_data, c("V1=Sepal_length", "V2=Sepal_width", "V3=Petal_length", "V4=Petal_width"))
names(iris)
irisInputs=iris[,-5]

#Use RandomForest
library(randomForest)
model <- randomForest(Species~.,
                      data=iris,
                      method="class"
)

summary(model)
plot(model)


#Create function from model to be updated to Azure Machine Learning
mypredict<- function(newdata)
{
  require(randomForest)#must be include
  predict(model,newdata,type = "response")
}


print(mypredict(iris))

if(!require(("devtools"))) install.packages("devtools")
devtools::install_github("RevolutionAnalytics/azureml")


library(azuremlsdk)
library(devtools)

wsID="98865ba0-64e9-4548-9d71-52fe37026cb7"
wsAuth="bb71e21d-8101-4b9c-987f-b5a375b32485"

wsobj=workspace(wsID,wsAuth)

#Create REST API

iriswebService<- publishWebService(
  wsobj,
  fun=mypredict,
  name="irisWebService",
  inputSchema = irisInputs
)
head(iriswebService)


install.packages(c("usethis", "gitcreds", "gh"))

usethis::use_git_config(user.name = "Dobie Bianca", user.email = "dobie.bianca16@gmail.com")
credentials::ssh_setup_github()

