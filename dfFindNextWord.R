library(qdap)

source("predictive-text-analysis/pkn/pkn.logical.dfchecker.R")

# 
# text <- c("a", "b", "c", "d")
# nwords <- length(text) #4
# newwords <- length(text)-2 #3
# text[1]
# text[-c(1:length(text) - length(text))]
# text[c(nwords-newwords+1):4]
# text[2:4]
# text[3:4]
# text[4:4]
# 


dfFindNextWord <- function(string, dictlist, n = 5){
    #string: a string whose next word you want to predict
    #dictionary: a list of dataframes for each ngram from 1 to 7
    #n is the number of words you want returned
    #RETURN: a df containing a ranked list of n words most likely to come next
    starttime <- Sys.time()
    
    #Reduce string: reduce to final sentence of string, by removing everything preceding ".?!"
    string <- sub(".*[.?!]+", "", string) #remove everything preceding .?!
    
    #Remove leading/trailing whitespace: 
    string <- sub("^\\s+|\\s+$", "", string) #remove leading and trailing whitespaces
    
    #to lowercase and expand contractions
    string <- tolower(replace_contraction(tolower(string)))
    
    #split into words by " "
    split <- unlist(strsplit(string, " "))
    
    #reduce string of x number of words to a string of y-1 of numbers, where y is the number of ngram dictionaries
    if(length(split) > length(dictlist) - 1) {
        split <- split[c(length(split)-length(dictlist) + 2) : length(split)] 
        cat("Warning: String too long; can not search for >", length(dictlist)-1," words. Shortening string...")
        cat("\n")
        cat("Reduced to: ")
        cat(split)
        cat("\n")
    }
    
    nwords <- length(split) +1
    
    dfnextword <- data.table(token = NA, count = NA) #creates dummy df with "invalid" numeric token

    #If no words are returned (all NAs), then use 1 less ngram to search:
    while(is.na(dfnextword[1,token]) == TRUE & nwords > 1){
        nwords = nwords - 1
        split <- split[c(length(split)-nwords+1):length(split)]
        print(c("[Search string]:"))
        cat(split)
        cat("\n")
        
        dfnextword <- dictlist[[nwords+1]][eval(parse(text=logical.dfchecker(dict_number = (nwords + 1),
                                                          token_start = 1, string = split,
                                                          string_start = 1,
                                                          ntokens = nwords))),]
        if(is.na(dfnextword[1,1]) == TRUE){
            if(nwords == 1){
                print(c("Error: Could not predict next word."))
                return()
            }
            #print(c("Current string not found; shortening by one word"))
            #cat("\n")
        }
    }
    #task: return NULL/throw error : use a different function to catch this error 
    #and add it to the dataframe
    #cat("\n")
    print("[TIME dfFindNextWord]")
    print(Sys.time() - starttime)
    cat("\n")
    cat("\n")
    result <- dfnextword[1:n,]
    result <- result[!is.na(result$count),] #remove NAs from result
    return(result)
}

#Example:
#dfFindNextWord("a b c d e f g japawefawefawerqwerqwerqerqan asdfasdfasdfasdf i cant wait to", dictlist, 3)

