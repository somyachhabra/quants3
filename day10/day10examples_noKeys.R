## Code for examples from Day 10, Social Media

library(quanteda)

##
## Facebook
##

# Access token: https://developers.facebook.com/tools/explorer/
token <- YOUR_TOKEN

require(Rfacebook)

## Scraping most recent 200 posts from Obama and McCain FB pages
obama <- getPage('barackobama', token = token, n = 20)
trump <- getPage('DonaldTrump', token = token, n = 20)

# creating corpus object
fbdata <- rbind(obama, trump)
fbcorpus <- corpus(fbdata$message, docvars = fbdata[, -which(names(fbdata)=="message")])
summary(fbcorpus)

# viewing the dfm using word clouds
plot(dfm(fbcorpus, ignoredFeatures = c(stopwords("english"), "ofa.bo", "http"), stem=TRUE, verbose = FALSE, groups = "from_name"),
     comparison = TRUE)



##
## Twitter
##

## data for authentication
## get your keys at apps.twitter.com
require(twitteR)
key <-
cons_secret <-
token <-
access_secret <-
# authorize the Twitter access
setup_twitter_oauth(key, cons_secret, token, access_secret)

## downloading 1,500 most recent tweets for an account
tw <- userTimeline("realDonaldTrump", n = 3200, includeRts = TRUE)
twDf <- twListToDF(tw)
twCorpus <- corpus(twDf$text, docvars = twDf[, -which(names(twDf)=="text")])
head(texts(twCorpus))
table(twCorpus[["isRetweet"]], useNA = "ifany")

## creating corpus and dfm objects, and word cloud
twDfm <- dfm(twCorpus, 
             ignoredFeatures = c("amp", "rt", "https", "t.co", "will", "@realdonaldtrump", stopwords("english")))
plot(twDfm, min.freq = 20, random.order = FALSE)

## analyze just hashtags
twDfmHT <- dfm(twCorpus, keptFeatures = c("#*"), toLower = FALSE)
plot(twDfmHT, min.freq = 5, random.order = FALSE)

## analyze just usernames
twDfmUN <- dfm(twCorpus, keptFeatures = c("@*"))
twDfmUN <- removeFeatures(twDfmUN, "@realdonaldtrump")
plot(twDfmUN, min.freq = 5, random.order = FALSE)


## analyze by candidate
twCruz <- userTimeline("tedcruz", n = 3200, includeRts = TRUE)
twCruzDf <- twListToDF(twCruz)
twCruzCorpus <- corpus(twCruzDf$text, docvars = twCruzDf[, -which(names(twCruzDf)=="text")])

candDfm <- dfm(twCorpus + twCruzCorpus, groups = "screenName",
               ignoredFeatures = c("amp", "rt", "https", "t.co", "will", "@tedcruz",
                                   "@realdonaldtrump", stopwords("english")))
plot(candDfm, comparison = TRUE)


## analyze time of tweets
# from which device?
device <- docvars(twCorpus, "statusSource")
device <- ifelse(grepl("Android", device), "Android", 
                 ifelse(grepl("iPhone", device), "iPhone",
                        ifelse(grepl("Web Client", device), "Web Client", NA)))
table(device, useNA = "ifany")
trumpDf <- data.frame(device, timeofDay = trumptimesDecimal)
par(mfrow = c(2,2))

# time of day - remove the day
time.ct   <- as.POSIXct(twCorpus[["created"]]) - 
    as.POSIXct(paste(substring(as.character(twCorpus[["created"]]), 1, 10), "00:00:00"))
time.hour <- as.POSIXlt(time.ct)$hour + as.POSIXlt(time.ct)$min/60

# plot
par(mfrow = c(2,2))
hist(subset(time.hour, device == "Android"), breaks = 48, ylim = c(0,100),
     col = "grey50", xlab = "24-hr time format", main = "Android", xaxt = "n")
axis(1, at = 0:24, cex = .7, labels = paste(0:24, "00", sep = ":"), las = 2)
hist(subset(time.hour, device == "iPhone"), breaks = 48, ylim = c(0,100),
     col = "grey60", xlab = "24-hr time format", main = "iPhone", xaxt = "n")
axis(1, at = 0:24, cex = .7, labels = paste(0:24, "00", sep = ":"), las = 2)
hist(subset(time.hour, device == "Web Client"), breaks = 48, ylim = c(0,100),
     col = "grey70", xlab = "24-hr time format", main = "Web Client", xaxt = "n")
axis(1, at = 0:24, cex = .7, labels = paste(0:24, "00", sep = ":"), las = 2)


###
### searching using REST API
### 
searchTweets <- searchTwitter("brexit", n = 1000, since = "2016-01-01")
searchTweetsDf <- twListToDF(searchTweets)
searchTweetsCorpus <- corpus(searchTweetsDf$text, docvars = searchTweetsDf[, -which(names(searchTweetsDf)=="text")])
searchTweetsDfm <- dfm(searchTweetsCorpus, verbose = FALSE, 
                       ignoredFeatures = c("amp", "rt", "https", "t.co", "will", stopwords("english")))
topfeatures(searchTweetsDfm, 30)
topfeatures(selectFeatures(searchTweetsDfm, "#*"), 30)






