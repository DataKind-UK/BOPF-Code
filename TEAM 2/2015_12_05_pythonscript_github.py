####################################################################################################################
#   Created: 2015_12_05
#   Created By: CDaly nidhalc@tcd.ie
#   Version: 1
#   Description: Links Gender and Number of survey respondents to the database of members and to geography
#       to establish if the survey data is representative of the membership base
####################################################################################################################

import pandas as pd
from pandas import DataFrame


def get_files(file_path1,file_path2,file_path3,file_path4):
    df_mem = pd.read_csv(file_path1)
    df_mem['TopLevelPostcode'] = df_mem['TopLevelPostcode'].map(lambda x: str(x)[:4].replace(' ',''))
    df_mem2 = df_mem
    df_mem1 = df_mem.drop(['LSOA11 Code','LSOA11 Name','Ward','Ward Code','Gender Unknown','Male','Female','Couple','On email','Email Newsletter'],axis = 1)
    df_mem1 = df_mem1.groupby(['TopLevelPostcode']).sum()
    df_mem1 = df_mem1.reset_index()
    df_mem2['Male_members'] = df_mem2['Male'].map(lambda x: 1 if str(x) == 'True' else 0)
    df_mem2['Female_members'] = df_mem2['Female'].map(lambda x: 1 if str(x) == 'True' else 0)
    df_mem2 = df_mem2.drop(['TopLevelPostcode','Male','Female','LSOA11 Name','Ward','Ward Code','Gender Unknown','Couple','On email','Email Newsletter'],axis = 1)
    df_mem2 = df_mem2.groupby(['LSOA11 Code']).sum()
    df_mem2 = df_mem2.reset_index()
    df_surv = pd.read_csv(file_path2)
    df_surv['TopLevelPostcode']= df_surv['Q9_PostCode']
    df_surv['Male_surv'] = df_surv['Q6_Gender'].map(lambda x: 1 if x == 'Male' else 0)
    df_surv['Female_surv'] = df_surv['Q6_Gender'].map(lambda x: 1 if x == 'Female' else 0)
    df_survey = df_surv[['TopLevelPostcode','Male_surv','Female_surv']]
    df_survey['TopLevelPostcode'] = df_survey['TopLevelPostcode'].fillna('Unknown')
    df_survey['Count'] = 1
    df_survey = df_survey.groupby(['TopLevelPostcode']).sum()
    df_survey = df_survey.reset_index()
    df_lookup_l = pd.read_csv(file_path3)
    df_lookup_l['TopLevelPostcode'] = df_lookup_l['TopPostCode']
    df_lookup_m = pd.read_csv(file_path4)
    #df_lookup_m['TopLevelPostcode'] = df_lookup_m['PCD8']
    df_lookup_m = df_lookup_m.drop(['PCD8','LSOA11_Name','MSOA11_Name','Ward_Code','Ward_Name'],axis = 1) 
    return df_mem1, df_survey, df_lookup_l,df_lookup_m, df_mem2
    
def logic(df1, df2,df3, df4, df5):
    ##by top level postcode
    merge_p = df1.merge(df2,how='outer',on=['TopLevelPostcode'])
    merge_p.to_csv(r'C:\Users\ChristinaDaly\Documents\Code Ninjas\DataKindUK\2015_Dec_DataDive\Insight.csv')
    ##bring survey and LSOA data together
    merge_l = DataFrame.merge(df2,df3,left_on=['TopLevelPostcode'],right_on=['TopLevelPostcode'],how='outer')
    merge_l['MSOA_Prob'] = merge_l['MSOA_Prob'].fillna(1)
    merge_l['MSOA_Code'] = merge_l['MSOA_Code'].fillna('Unknown')
    merge_l['Male_surv'] = merge_l['Male_surv'] * merge_l['MSOA_Prob']
    merge_l['Female_surv'] = merge_l['Female_surv'] * merge_l['MSOA_Prob']
    merge_l['Respondent Number'] = merge_l['Count'] * merge_l['MSOA_Prob']
    merge_l = merge_l.drop(['TopLevelPostcode','TopPostCode','MSOA_Count'],axis = 1)
    merge_l = merge_l.groupby(['MSOA_Code']).sum()
    merge_l = merge_l.reset_index()
    ###merge_l.to_csv(r'')
    ##bring membership and LSOA data together
    merge_m = DataFrame.merge(df5,df4,left_on=['LSOA11 Code'],right_on=['LSOA11CD'],how='outer')
    merge_m = merge_m.drop_duplicates()
    merge_m = merge_m.drop(['LSOA11 Code','LSOA11CD'],axis = 1)
    merge_m = merge_m.groupby(['MSOA11_Code']).sum()
    merge_m = merge_m.reset_index()
    ###merge_m.to_csv(r'')
    ##join the membership and survey data together using the common LSOA to do so
    merge_all = DataFrame.merge(merge_m,merge_l,left_on=['MSOA11_Code'],right_on=['MSOA_Code'],how='outer')
    merge_all_with_nonmatches = merge_all
    ##get rid of non matches (~63 respondents that don't match geographically)
    merge_all = merge_all[merge_all['MSOA11_Code'].notnull()]
    ##scale according to the total response vs membership base (Respondents)
    sum_members = df1['NoMembers'].sum()
    sum_surveyed = merge_all['Respondent Number'].sum()
    scaling = float(1)/sum_members*sum_surveyed
    merge_all['NoMembers_Scaled'] = merge_all['NoMembers'] * scaling
    merge_all['representative_response'] = 1/merge_all['NoMembers_Scaled']*merge_all['Respondent Number'] 
    ##scale according to total response vs membership base (Gender)
    sum_members_m = df5['Male_members'].sum()
    sum_surveyed_m = merge_all['Male_surv'].sum()
    scaling = float(1)/sum_members_m*sum_surveyed_m
    merge_all['NoMembers_Scaled_Male'] = merge_all['Male_members'] * scaling
    merge_all['representative_response_male'] = 1/merge_all['NoMembers_Scaled_Male']*merge_all['Male_surv'] 
    sum_members_f = df5['Female_members'].sum()
    sum_surveyed_f = merge_all['Female_surv'].sum()
    scaling = float(1)/sum_members_m*sum_surveyed_m
    merge_all['NoMembers_Scaled_Female'] = merge_all['Female_members'] * scaling
    merge_all['representative_response_female'] = 1/merge_all['NoMembers_Scaled_Female']*merge_all['Female_surv'] 
    
    return merge_all
    
if __name__ == "__main__":
    membership_database = r'' #put directory link to csv inside quotation marks
    newsletter_survey = r'' #put directory link to csv inside quotation marks
    TopLevelPostcode_to_MSOA_Prob = r'' #put directory link to csv inside quotation marks
    Bristol_Postcode_LSOA_MSOA_Ward_map = r'' #put directory link to csv inside quotation marks
    
    #takes location of files and returns dataframes to work with 
    df1, df2,df3, df4, df5 = get_files(membership_database,newsletter_survey,TopLevelPostcode_to_MSOA_Prob,Bristol_Postcode_LSOA_MSOA_Ward_map)
    #takes dataframes and performs logic to return final dataframe
    merge_all = logic(df1, df2,df3, df4, df5)
    
    #Output File Put Link to where want to save file in the directory
    merge_all.to_csv(r'')
