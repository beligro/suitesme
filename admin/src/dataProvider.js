import { fetchUtils } from 'react-admin';
import jsonServerProvider from 'ra-data-json-server';

// Use relative URL instead of hardcoded IP
const apiUrl = '/admin/v1';

const httpClient = (url, options = {}) => {
  if (!options.headers) {
    options.headers = new Headers({ 'Content-Type': 'application/json' });
  }
  const token = localStorage.getItem('auth');
  options.headers.set('Authorization', `Bearer ${token}`);
  return fetchUtils.fetchJson(url, options);
};

const defaultDataProvider = jsonServerProvider(apiUrl, httpClient);

const dataProvider = {
  ...defaultDataProvider,
  
  // Override getList to handle custom statistics endpoint
  getList: (resource, params) => {
    // Handle statistics endpoint
    if (resource === 'predictions-statistics') {
      return httpClient(`${apiUrl}/predictions-statistics`, {
        method: 'GET',
      }).then(({ json }) => ({
        data: [json], // Wrap in array for react-admin
        total: 1,
      }));
    }
    
    // Use default implementation for other resources
    return defaultDataProvider.getList(resource, params);
  },
  
  // Override getOne method to handle styles resource
  getOne: (resource, params) => {
    console.log('getOne', resource, params);
    
    // Use the default implementation
    return defaultDataProvider.getOne(resource, params);
  },
  
  // Override create method to handle file uploads
  create: (resource, params) => {
    if (resource !== 'styles' || !params.data.pdf_file) {
      // If not uploading a file, use the default implementation
      return defaultDataProvider.create(resource, params);
    }

    // Handle file upload
    const formData = new FormData();
    
    // Add non-file fields to the form data
    Object.keys(params.data).forEach(key => {
      if (key !== 'pdf_file') {
        formData.append(key, params.data[key]);
      }
    });
    
    // Add the file to the form data
    if (params.data.pdf_file && params.data.pdf_file.rawFile) {
      formData.append('pdf_file', params.data.pdf_file.rawFile);
    }

    return httpClient(`${apiUrl}/${resource}`, {
      method: 'POST',
      body: formData,
      headers: new Headers({
        Authorization: `Bearer ${localStorage.getItem('auth')}`,
      }),
    }).then(({ json }) => ({
      data: { ...params.data, id: json.id },
    }));
  },

  // Override update method to handle file uploads
  update: (resource, params) => {
    if (resource !== 'styles' || !params.data.pdf_file) {
      // If not uploading a file, use the default implementation
      return defaultDataProvider.update(resource, params);
    }

    // Handle file upload
    const formData = new FormData();
    
    // Add non-file fields to the form data
    Object.keys(params.data).forEach(key => {
      if (key !== 'pdf_file') {
        formData.append(key, params.data[key]);
      }
    });
    
    // Add the file to the form data if it's a new file
    if (params.data.pdf_file && params.data.pdf_file.rawFile) {
      formData.append('pdf_file', params.data.pdf_file.rawFile);
    }

    return httpClient(`${apiUrl}/${resource}/${params.id}`, {
      method: 'PUT',
      body: formData,
      headers: new Headers({
        Authorization: `Bearer ${localStorage.getItem('auth')}`,
      }),
    }).then(({ json }) => ({ data: json }));
  },
};

export default dataProvider;
