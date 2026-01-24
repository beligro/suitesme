import * as React from "react";
import { 
  Edit, 
  SimpleForm, 
  TextInput, 
  SelectInput, 
  DateField,
  BooleanField,
  FormDataConsumer,
  FunctionField,
  useTheme,
  Button,
  useRecordContext,
  useRedirect,
  useNotify,
  useUpdate
} from "react-admin";
import { useFormContext } from "react-hook-form";

// ML Service classes - from the face classifier API
const ML_CLASSES = [
  'Aristocratic',
  'Business',
  'Fire',
  'Fragile',
  'Heroin',
  'Inferno',
  'Melting',
  'Queen',
  'Renaissance',
  'Serious',
  'Soft',
  'Strong',
  'Sunny',
  'Vintage',
  'Warm'
];

// Component to display all uploaded photos
const PhotoGallery = ({ record }) => {
  const [theme] = useTheme();
  const isDark = theme === 'dark';
  
  if (!record || !record.photoUrls) return null;
  
  let photoUrls = [];
  try {
    photoUrls = typeof record.photoUrls === 'string' 
      ? JSON.parse(record.photoUrls) 
      : record.photoUrls;
  } catch (e) {
    return <div>Error loading photos</div>;
  }

  return (
    <div style={{ marginBottom: 20 }}>
      <h3>Uploaded Photos</h3>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))', gap: 16 }}>
        {photoUrls.map((url, index) => (
          <div key={index} style={{ 
            border: `1px solid ${isDark ? '#555' : '#ddd'}`, 
            borderRadius: 4, 
            overflow: 'hidden',
            backgroundColor: isDark ? '#2a2a2a' : '#fff'
          }}>
            <img 
              src={url} 
              alt={`Photo ${index + 1}`} 
              style={{ width: '100%', height: 200, objectFit: 'cover' }}
            />
            <div style={{ 
              padding: 8, 
              fontSize: 12, 
              textAlign: 'center', 
              background: isDark ? '#333' : '#f5f5f5',
              color: isDark ? '#fff' : '#000'
            }}>
              Photo {index + 1}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

// Accept Button Component
const AcceptButton = () => {
  const record = useRecordContext();
  const [theme] = useTheme();
  const isDark = theme === 'dark';
  const redirect = useRedirect();
  const notify = useNotify();
  const [update, { isLoading }] = useUpdate();

  if (!record || record.isVerified) return null;

  const handleAccept = () => {
    update(
      'predictions',
      { 
        id: record.id, 
        data: { styleId: record.initialPrediction },
        previousData: record 
      },
      {
        onSuccess: () => {
          notify('Prediction accepted and saved successfully', { type: 'success' });
          redirect('list', 'predictions');
        },
        onError: (error) => {
          notify(`Error: ${error.message}`, { type: 'error' });
        }
      }
    );
  };

  return (
    <Button
      label="Accept Prediction"
      onClick={handleAccept}
      variant="contained"
      disabled={isLoading}
      style={{
        marginBottom: 16,
        backgroundColor: isDark ? '#2e7d32' : '#4caf50',
        color: '#fff'
      }}
    />
  );
};

// Edit component for verifying predictions
export const PredictionsEdit = props => {
  const [theme] = useTheme();
  const isDark = theme === 'dark';

  // Use ML classes for the dropdown
  const styleChoices = ML_CLASSES.map(className => ({ 
    id: className, 
    name: className 
  }));

  return (
    <Edit {...props}>
      <SimpleForm>
        <FunctionField render={record => <PhotoGallery record={record} />} />
        
        <div style={{ 
          padding: 16, 
          background: isDark ? '#2a2a2a' : '#f5f5f5', 
          borderRadius: 4, 
          marginBottom: 20,
          border: `1px solid ${isDark ? '#555' : '#ddd'}`,
          color: isDark ? '#fff' : '#000'
        }}>
          <h3 style={{ marginTop: 0 }}>Prediction Information</h3>
          <div>
            <strong>ML Predicted Class:</strong>
            <FunctionField render={record => (
              <div style={{ fontSize: 24, color: isDark ? '#90caf9' : '#1976d2', marginTop: 8, fontWeight: 'bold' }}>
                {record.initialPrediction}
              </div>
            )} />
          </div>
          <div style={{ marginTop: 16 }}>
            <strong>User ID:</strong>
            <TextInput source="userId" disabled fullWidth />
          </div>
        </div>

        <div style={{ 
          padding: 16, 
          background: isDark ? '#3a2a1a' : '#fff3e0', 
          borderRadius: 4, 
          marginBottom: 20,
          border: `1px solid ${isDark ? '#ff9800' : '#ff9800'}`,
          color: isDark ? '#fff' : '#000'
        }}>
          <h3 style={{ marginTop: 0 }}>Verify Prediction</h3>
          
          <AcceptButton />
          
          <SelectInput 
            source="styleId" 
            label="Or Choose Different Style Class"
            choices={styleChoices}
            fullWidth
            helperText="Click 'Accept Prediction' above if the ML prediction is correct, or select a different class"
          />
        </div>

        <FormDataConsumer>
          {({ formData }) => formData.isVerified && (
            <div style={{ 
              padding: 16, 
              background: isDark ? '#1a2a1a' : '#e8f5e9', 
              borderRadius: 4, 
              marginBottom: 20,
              border: `1px solid ${isDark ? '#4caf50' : '#4caf50'}`,
              color: isDark ? '#fff' : '#000'
            }}>
              <h3 style={{ marginTop: 0 }}>Verification Status</h3>
              <BooleanField source="isVerified" label="Verified" />
              <DateField source="verifiedAt" label="Verified At" showTime />
              <TextInput source="verifiedBy" label="Verified By Admin ID" disabled />
            </div>
          )}
        </FormDataConsumer>

        <TextInput disabled source="id" fullWidth />
        <DateField source="createdAt" label="Created At" showTime />
        <DateField source="updatedAt" label="Updated At" showTime />
      </SimpleForm>
    </Edit>
  );
};

