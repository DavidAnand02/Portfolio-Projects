#R Assessment for candidate number 42174 - ST227


#Q3, Part A

#Get mu, get tpx, density is tps * mu



lamda <- 0.0001
gamma <- 0.02

mu <- function(t){
  
  lamda+gamma*log(log(t + exp(1)))
  
}



#Get tpx, vectorised in case of using multiple values of t


tpx <- function(t,x){
  
  sapply(
    1:length(t),
    function(t){
      exp(-integrate(mu, lower = x, upper = t+x)$value)
      
    }
    
  )
  
}

#1/2 way through exam, so treat age x = 1 hours, t = remaining time 1 hours
#ignoring upload time
#in minutes

density <- function(t){ 
  
  tpx(t = 60, x = 60) * mu(60 + 60)
  
}

density


#Part bi of Q1

#the expected number of minutes it will take you to finish the exam
#like expected curtate lifetime


integrand <- function(t){
  
  t*density(t)
  
}

integrate(integrand, lower = 0, upper = 120)
#using 120 mins as the for upper limit of values that t can take, because thats the time for the exam




#in minutes
#bii probability of handing it in time - submitting within the 3 hours


tpx(t = 60, x = 60)



#Q4 part A, first put data into dataframe
#Add a categorical variable called censored to your data frame taking value 0 if you believe the student did not
#finish the whole exam and 1 else.

#the alloted time is 120 minutes so if their time taken is 120 mins then assume they didn't finish on time

load(ST227Q4)
student_data <- as.data.frame(ST227Q4)

head(student_data)



student_data


student_data$censored <- ifelse(student_data$time == 120, 0, 1)


student_data

#to get the output you need to load the data into the global environment

#Q4 part B


install.packages("survival")
library("survival")  #Library to load the packages up



SurvObject <- Surv(time = student_data$time, event = student_data$censored) 

coxmodel <- coxph(SurvObject ~ revised, data = student_data) # coxph regresses the survival object against whether or not they revised


coxmodel

summary(coxmodel)


#as all the probabilities are less than 2e-16, all tests show that the critical value is not in the critical region
# so insufficient evidence to reject H0, the null hypothesis


#Q4 part c


#In no more than 50 words explain how you could repeat the same analysis using the KaplanMeier estimator.






#Q2 part a, slight mistake on the paper, it calls part A, part B
#getting data from ST227 Q1


parameter_data <- as.data.frame(ST227Q1)

head(parameter_data)

w <- parameter_data$w

v <- parameter_data$v

s <- parameter_data$s
r <- parameter_data$r
d <- parameter_data$d
u <- parameter_data$u



nLL <- function(params){
  
  
  sigma <- params[1]  
  mew <- params[2]
  rho <- params[3]
  nu <- params[4]
  
  -( -(sigma+mew)*v -(rho + nu)*w + d*log(mew) + u*log(nu) 
     
     + r*log(sigma) + s*log(rho)
  
  )
  
}



#Now optimise it using optim, since it has 4 parameters using default optim, if 1 then use Brent



result <- optim(par = c(1, 1, 1, 1), nLL,) 



MLE_sigma <- result$par[1]

MLE_mew <- result$par[2]

MLE_rho <- result$par[3]

MLE_nu <- result$par[4]


#Error - having trouble here, I was trying to get the MLE values from optim but maybe I'm not using the right values for the parameters
# not sure the issue, but I would then get the individual MLE's from the result using subsetting



#instead I'll just use the formulas I derived from paper

MLE_sigma <- (parameter_data$r)/parameter_data$v
MLE_sigma
head(MLE_sigma)

MLE_mew <- (parameter_data$d)/parameter_data$v
MLE_mew
head(MLE_mew)

MLE_rho <- (parameter_data$s)/parameter_data$w
MLE_rho
head(MLE_rho)

MLE_nu <- (parameter_data$u)/parameter_data$w
MLE_nu
head(MLE_nu)




#Q2 part b, on exam its called part c


# Compute the test statistic
test_statistic <- MLE_mew - MLE_nu

#Not sure about the distribution but assuming asymptotic normality for large n, I'll go with the normal distribution

# Compute the p-value using the cumulative distribution function (CDF) of the normal distribution
p_value <- pnorm(test_statistic)

# Compare the p-value with the significance level (alpha = 0.05)
alpha <- 0.05

if (p_value < alpha) {
  cat("Reject the null hypothesis H0: µ = ??. There is sufficient evidence to conclude that µ is less than ?? at the 95% confidence level.")
} else {
  cat("Don't reject the null hypothesis H0: µ = ??. There is not enough evidence to support the claim that µ is less than ?? at the 95% confidence level.")
}



#used the cat function to give my interpretation, 
#if you check output it should say don't reject the null hypothesis H0: µ = ??. There is not enough evidence to support the claim that µ is less than ?? at the 95% confidence level



#I get output for most things except at the end for the MLE's using optim

#I did question 1 on paper - fisher information matrix and derivation of the MLE's

















