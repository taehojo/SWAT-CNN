import pandas as pd
import scipy.stats as st

# Importing dataset
data = pd.read_csv('result.all', header=None, delim_whitespace=True)

# Normalizing the dataset using z-scores
normalized_data = (data - data.mean()) / (data.std())

# Assigning p-values
p_values = st.norm.sf(abs(normalized_data[2]))
p_value_data = pd.DataFrame(p_values)

# Merging the data
data[3] = normalized_data[2]
data[4] = p_value_data

# Saving the results to a new file
data.to_csv('final_score.csv.norm')
