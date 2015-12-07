
# coding: utf-8

## 55+ confession and fear of crime in the Bristol Quality of Life Survey

# In[2]:

get_ipython().magic(u'pylab inline')
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib
import seaborn as sns

plt.style.use('ggplot')


# #Attributes
# ##religion (categoric)
# * buddihst
# * christian
# * hindu
# * jewish
# * muslim
# * none
# * other
# * sikh
# 
# ##U60 (categoric) - "Fear of crime affects my day-to-day life"
# * disagree
# * neither/nor
# * strongly agree
# * strongly disagree
# * tend to agree
# 
# ## uhrn - encodes year of the survey
# 
# #Data
# "qol55.csv" = "qol_2006-2014_clean.csv" stripped of every row with age < 55

# In[3]:

qol = pd.read_csv('qol55.csv')
crime = qol[['religion', 'U60', 'uhrn']]


# In[39]:

likert = ["strongly disagree", "disagree", "neither/nor", "tend to agree", "strongly agree"]
crime_ser = pd.Series(crime['U60'])
crime["fearOfCrime"] = pd.Categorical(crime_ser, likert, ordered=True)


# In[40]:

crime.groupby(['religion','fearOfCrime'])['fearOfCrime'].count()


# In[36]:

#selecting only the 2014 survey results
crime14 = crime[crime.uhrn.str.contains('^14')]


# In[50]:

def plot_fear_of_crime_for_confession(df, confess, pos=0, width=0.1, color='green'):
    group = df[df['religion'] == confess]
    n = len(group)
    label = confess + " (N=" + str(n) + ")"
    value_counts = group['fearOfCrime'].value_counts(normalize=True, sort=False)
    value_counts.plot(kind='bar', color=color, ax=ax, position=pos, width=width, label=label)


# In[55]:

fig = plt.figure(figsize=(10,6))
plt.title("55+ fear of crime by confession in the Bristol QoL Survey")
ax = fig.add_subplot(111)
ax.set_ylabel('% of confessional group')
ax.set_xlabel('"Fear of crime affects my day-to-day life"')

plot_fear_of_crime_for_confession(crime,'christian', pos=0, color='#747F8C')
plot_fear_of_crime_for_confession(crime, 'muslim', pos=1, color='#F2CC85')
plot_fear_of_crime_for_confession(crime, 'jewish', pos=2, color='#BF7245')
plot_fear_of_crime_for_confession(crime, 'none', pos=3, color='#4E4E59')

ax.legend(loc='center left', bbox_to_anchor=(1, 0.5))
plt.show()

