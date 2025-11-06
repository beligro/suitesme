import * as React from "react";
import { useState, useEffect } from "react";
import { Card, CardContent, Typography, Grid, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, CircularProgress } from "@mui/material";
import { useDataProvider, Title } from "react-admin";

export const PredictionsStatistics = () => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const dataProvider = useDataProvider();

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const response = await dataProvider.getList('predictions-statistics', {
          pagination: { page: 1, perPage: 1 },
          sort: { field: 'id', order: 'ASC' },
          filter: {}
        });
        setStats(response.data);
        setLoading(false);
      } catch (error) {
        console.error("Error fetching statistics:", error);
        setLoading(false);
      }
    };

    fetchStats();
  }, [dataProvider]);

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', padding: 40 }}>
        <CircularProgress />
      </div>
    );
  }

  if (!stats) {
    return <div>No statistics available</div>;
  }

  const { 
    totalPredictions, 
    verifiedCount, 
    unverifiedCount, 
    accuracyRate,
    confusionMatrix,
    perClassAccuracy,
    confidenceDistribution
  } = stats;

  return (
    <div style={{ padding: 20 }}>
      <Title title="Prediction Statistics" />
      
      {/* Overview Cards */}
      <Grid container spacing={3} style={{ marginBottom: 30 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                Total Predictions
              </Typography>
              <Typography variant="h4" component="div">
                {totalPredictions}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                Verified
              </Typography>
              <Typography variant="h4" component="div" style={{ color: '#4caf50' }}>
                {verifiedCount}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                Unverified
              </Typography>
              <Typography variant="h4" component="div" style={{ color: '#ff9800' }}>
                {unverifiedCount}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                Accuracy Rate
              </Typography>
              <Typography variant="h4" component="div" style={{ color: '#2196f3' }}>
                {accuracyRate ? accuracyRate.toFixed(1) : 0}%
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Confidence Distribution */}
      <Card style={{ marginBottom: 30 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Confidence Distribution
          </Typography>
          <Grid container spacing={2}>
            <Grid item xs={4}>
              <Paper style={{ padding: 16, textAlign: 'center', background: '#ffebee' }}>
                <Typography variant="h6" style={{ color: '#f44336' }}>
                  {confidenceDistribution?.low || 0}
                </Typography>
                <Typography color="textSecondary">
                  Low (0-33%)
                </Typography>
              </Paper>
            </Grid>
            <Grid item xs={4}>
              <Paper style={{ padding: 16, textAlign: 'center', background: '#fff3e0' }}>
                <Typography variant="h6" style={{ color: '#ff9800' }}>
                  {confidenceDistribution?.medium || 0}
                </Typography>
                <Typography color="textSecondary">
                  Medium (34-66%)
                </Typography>
              </Paper>
            </Grid>
            <Grid item xs={4}>
              <Paper style={{ padding: 16, textAlign: 'center', background: '#e8f5e9' }}>
                <Typography variant="h6" style={{ color: '#4caf50' }}>
                  {confidenceDistribution?.high || 0}
                </Typography>
                <Typography color="textSecondary">
                  High (67-100%)
                </Typography>
              </Paper>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Per-Class Accuracy */}
      {perClassAccuracy && Object.keys(perClassAccuracy).length > 0 && (
        <Card style={{ marginBottom: 30 }}>
          <CardContent>
            <Typography variant="h6" gutterBottom>
              Per-Class Accuracy
            </Typography>
            <TableContainer component={Paper} variant="outlined">
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell><strong>Class</strong></TableCell>
                    <TableCell align="right"><strong>Accuracy</strong></TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {Object.entries(perClassAccuracy).map(([className, accuracy]) => (
                    <TableRow key={className}>
                      <TableCell>{className}</TableCell>
                      <TableCell align="right">
                        <span style={{ 
                          color: accuracy >= 80 ? '#4caf50' : accuracy >= 60 ? '#ff9800' : '#f44336',
                          fontWeight: 'bold'
                        }}>
                          {accuracy.toFixed(1)}%
                        </span>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </CardContent>
        </Card>
      )}

      {/* Confusion Matrix */}
      {confusionMatrix && Object.keys(confusionMatrix).length > 0 && (
        <Card>
          <CardContent>
            <Typography variant="h6" gutterBottom>
              Confusion Matrix
            </Typography>
            <Typography variant="body2" color="textSecondary" paragraph>
              Rows: Initial Prediction | Columns: Verified Prediction
            </Typography>
            <TableContainer component={Paper} variant="outlined">
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell><strong>Initial \ Verified</strong></TableCell>
                    {Object.keys(confusionMatrix).map(className => (
                      <TableCell key={className} align="center">
                        <strong>{className}</strong>
                      </TableCell>
                    ))}
                  </TableRow>
                </TableHead>
                <TableBody>
                  {Object.entries(confusionMatrix).map(([initialClass, verifiedClasses]) => (
                    <TableRow key={initialClass}>
                      <TableCell component="th" scope="row">
                        <strong>{initialClass}</strong>
                      </TableCell>
                      {Object.keys(confusionMatrix).map(verifiedClass => {
                        const count = verifiedClasses[verifiedClass] || 0;
                        const isCorrect = initialClass === verifiedClass;
                        return (
                          <TableCell 
                            key={verifiedClass} 
                            align="center"
                            style={{ 
                              background: isCorrect ? '#e8f5e9' : count > 0 ? '#ffebee' : 'transparent',
                              fontWeight: isCorrect ? 'bold' : 'normal'
                            }}
                          >
                            {count || '-'}
                          </TableCell>
                        );
                      })}
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </CardContent>
        </Card>
      )}
    </div>
  );
};

