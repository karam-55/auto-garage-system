const SUPABASE_URL = 'https://epiqlptgiqskizfgmagj.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVwaXFscHRnaXFza2l6ZmdtYWdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MTY2ODgsImV4cCI6MjA5NDE5MjY4OH0.9__a_Y3mMvpH456Go4MF9TKmObytZO0bOF761wagGuY';

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    
    // Handle auth endpoints
    if (url.pathname === '/api/auth/login' && request.method === 'POST') {
      return await handleLogin(request);
    }
    
    // Handle mechanic endpoints
    if (url.pathname === '/api/mechanics/available-bookings' && request.method === 'GET') {
      return await handleAvailableBookings(request);
    }
    
    if (url.pathname === '/api/mechanics/assign' && request.method === 'POST') {
      return await handleAssignBooking(request);
    }
    
    if (url.pathname === '/api/mechanics/my-assignments' && request.method === 'GET') {
      return await handleMyAssignments(request);
    }
    
    if (url.pathname.startsWith('/api/mechanics/assignments/') && url.pathname.endsWith('/status') && request.method === 'PATCH') {
      const assignmentId = url.pathname.split('/')[4];
      return await handleUpdateAssignmentStatus(request, assignmentId);
    }
    
    if (url.pathname.match(/\/api\/mechanics\/bookings\/[^/]+\/part-suggestions/) && request.method === 'POST') {
      const bookingId = url.pathname.split('/')[4];
      return await handleCreatePartSuggestion(request, bookingId);
    }
    
    if (url.pathname.match(/\/api\/mechanics\/bookings\/[^/]+\/part-suggestions/) && request.method === 'GET') {
      const bookingId = url.pathname.split('/')[4];
      return await handleGetPartSuggestions(request, bookingId);
    }
    
    // Default response for unknown endpoints
    return new Response(JSON.stringify({ error: 'Endpoint not found' }), {
      status: 404,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  },
};

async function handleAvailableBookings(request) {
  try {
    const targetUrl = new URL('/rest/v1/bookings?status=eq.PENDING&select=*,vehicles:vehicle_id(*),customers:customer_id(*)', SUPABASE_URL);
    
    const response = await fetch(targetUrl, {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
    });
    
    const data = await response.json();
    
    return new Response(JSON.stringify(data), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: 'Error: ' + error.message }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  }
}

async function handleAssignBooking(request) {
  try {
    const body = await request.json();
    const { bookingId } = body;
    
    // For now, we'll need the mechanic user ID from the token
    // This is a simplified version - in production, validate the token
    const targetUrl = new URL('/rest/v1/mechanic_assignments', SUPABASE_URL);
    
    const response = await fetch(targetUrl, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        booking_id: bookingId,
        mechanic_user_id: body.mechanicUserId,
        status: 'ASSIGNED',
      }),
    });
    
    return new Response(response.body, {
      status: response.status,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: 'Error: ' + error.message }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  }
}

async function handleMyAssignments(request) {
  try {
    const mechanicUserId = request.headers.get('X-Mechanic-User-Id');
    if (!mechanicUserId) {
      return new Response(JSON.stringify({ error: 'Missing mechanic user ID' }), {
        status: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      });
    }
    
    const targetUrl = new URL(`/rest/v1/mechanic_assignments?mechanic_user_id=eq.${mechanicUserId}&select=*,bookings(*)`, SUPABASE_URL);
    
    const response = await fetch(targetUrl, {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
    });
    
    const data = await response.json();
    
    return new Response(JSON.stringify(data), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: 'Error: ' + error.message }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  }
}

async function handleUpdateAssignmentStatus(request, assignmentId) {
  try {
    const body = await request.json();
    const { status, notes } = body;
    
    const targetUrl = new URL(`/rest/v1/mechanic_assignments?id=eq.${assignmentId}`, SUPABASE_URL);
    
    const response = await fetch(targetUrl, {
      method: 'PATCH',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        status,
        notes,
        updated_at: new Date().toISOString(),
      }),
    });
    
    return new Response(response.body, {
      status: response.status,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: 'Error: ' + error.message }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  }
}

async function handleCreatePartSuggestion(request, bookingId) {
  try {
    const body = await request.json();
    const { type, description, priceSYP } = body;
    
    const targetUrl = new URL('/rest/v1/part_suggestions', SUPABASE_URL);
    
    const response = await fetch(targetUrl, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        booking_id: bookingId,
        mechanic_user_id: body.mechanicUserId,
        type,
        description,
        price_syp: priceSYP,
        status: 'PENDING_CUSTOMER_APPROVAL',
      }),
    });
    
    return new Response(response.body, {
      status: response.status,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: 'Error: ' + error.message }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  }
}

async function handleGetPartSuggestions(request, bookingId) {
  try {
    const targetUrl = new URL(`/rest/v1/part_suggestions?booking_id=eq.${bookingId}`, SUPABASE_URL);
    
    const response = await fetch(targetUrl, {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
    });
    
    const data = await response.json();
    
    return new Response(JSON.stringify(data), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: 'Error: ' + error.message }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  }
}
