import * as React from "react";
import { 
  List, 
  Datagrid, 
  TextField, 
  DateField, 
  BooleanField, 
  EditButton,
  Filter,
  BooleanInput,
  FunctionField,
  NumberField
} from "react-admin";

// Filter component for predictions
const PredictionFilter = (props) => (
  <Filter {...props}>
    <BooleanInput label="Verified Only" source="isVerified" alwaysOn />
  </Filter>
);

// Custom field to display first photo thumbnail
const PhotoField = ({ record }) => {
  if (!record || !record.photoUrls) return null;
  
  let photoUrls = [];
  try {
    photoUrls = typeof record.photoUrls === 'string' 
      ? JSON.parse(record.photoUrls) 
      : record.photoUrls;
  } catch (e) {
    return null;
  }

  if (!photoUrls.length) return null;

  return (
    <img 
      src={photoUrls[0]} 
      alt="User" 
      style={{ width: 50, height: 50, objectFit: 'cover', borderRadius: 4 }}
    />
  );
};

// List of predictions
export const PredictionsList = props => (
  <List 
    {...props} 
    filters={<PredictionFilter />}
    sort={{ field: 'createdAt', order: 'DESC' }}
  >
    <Datagrid rowClick="edit">
      <FunctionField label="Photo" render={record => <PhotoField record={record} />} />
      <TextField source="userId" label="User ID" />
      <TextField source="initialPrediction" label="Initial Prediction" />
      <NumberField 
        source="confidence" 
        label="Confidence" 
        options={{ style: 'percent', minimumFractionDigits: 1, maximumFractionDigits: 1 }}
      />
      <TextField source="verifiedPrediction" label="Verified As" />
      <BooleanField source="isVerified" label="Verified" />
      <DateField source="createdAt" label="Created" showTime />
      <EditButton />
    </Datagrid>
  </List>
);

