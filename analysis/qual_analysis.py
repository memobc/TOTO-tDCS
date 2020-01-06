"""
Quail Analysis
"""

import pandas as pd # a tidyverse esq python data manipulation package
import quail as q # andy's free recall package
import numpy as np # arrary manipulation

# Goal: turn `study` data.frame into a lists of lists
 
# read in recall and study data frames
study = pd.read_csv('~/Desktop/study.csv')
 
# initialize two variables `presented_words` and `presented_word_features`, 
# which will be used to create the egg.
presented_words = []
presented_word_features = []
 
# for each subject...
for s in study['subjectID'].unique():
 
    # all of the data related to the current subject
    cur_sub = study[study['subjectID'] == s]
    
    # initalizing temporary variables to hold the words 
    # on this list and the features of the words on this list
    lists = []
    lists_features = []
    
    for ses in cur_sub['sessionID'].unique():
    
      cur_sub_cur_ses = cur_sub[cur_sub['sessionID'] == ses]
  
      # for each list...
      for l in cur_sub_cur_ses['listID'].unique():
      
          # current list subset of cur_sub_cur_ses data.frame
          cur_list = cur_sub_cur_ses[cur_sub_cur_ses['listID'] == l]
  
          # the words presented on this list
          words = list(cur_list['Word'])
  
          # force lowercase
          words = list(map(str.lower, words))
  
          # append
          lists.append(words)
          lists_features.append(cur_list[['EmotionCategory']].to_dict(orient='records'))
 
    # append
    presented_words.append(lists)
    presented_word_features.append(lists_features)
    
# Goal: turn `recall` data.frame into a lists of lists. 
# Note: must match the order of the `study` data.frame

recall = pd.read_csv('~/Desktop/recall.csv')

# initalize a list of recalled words
recalled_words = []

# for each subject...
for s in study['subjectID'].unique():
    
    # the current subject's encoding (or study) data
    cur_sub = study[study['subjectID'] == s]
    
    # initialize a temporary variable to hold the recalled words
    lists = []
    
    for ses in cur_sub['sessionID'].unique():
    
        # current subject current sessionID
        cur_sub_cur_ses = cur_sub[cur_sub['sessionID'] == ses]
    
        # for each list from **encoding/study**...
        for l in cur_sub_cur_ses['listID'].unique():
        
            # the current list from **recall**
            cur_list = recall[np.array(recall['listID'] == l) & np.array(recall['subjectID'] == s) & np.array(recall['sessionID'] == ses)]
    
            # words recalled from this list for this subject
            words = cur_list.iloc[:, 0].tolist()
    
            # remove tildes (~) in words
            while '~' in words:
                words.remove('~')
    
            # remove question marks (?) in words
            while '?' in words:
                words.remove('?')
                
            if words == "emptyFile":
                words = []
    
            # remove nans
            c = -1
            for w in words:
                c = c + 1            
                if type(w) != str:
                    words[c] = ''
    
            # strip leading and trailing white space
            c = -1
            for w in words:
                c = c + 1            
                words[c] = words[c].strip()
    
            # force the words to be lowercase and append
            lists.append(list(map(str.lower, words)))

    # append
    recalled_words.append(lists)
    
# create an egg
egg = q.Egg(pres=presented_words, rec=recalled_words, features=presented_word_features)

# Analayze Accuracy
acc = egg.analyze('accuracy')
acc_as_DF = acc.get_data()
acc_as_DF.to_csv('~/Desktop/accuracy.csv')

# Analyze Temporal Contiguity
temporal = egg.analyze('temporal')
temporal_as_DF = temporal.get_data()
temporal_as_DF.to_csv('~/Desktop/temporal.csv')
