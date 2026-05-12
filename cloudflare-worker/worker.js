const SUPABASE_URL = 'https://epiqlptgiqskizfgmagj.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVwaXFscHRnaXFza2l6ZmdtYWdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MTY2ODgsImV4cCI6MjA5NDE5MjY4OH0.9__a_Y3mMvpH456Go4MF9TKmObytZO0bOF761wagGuY';

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    
    // Handle auth endpoints
    if (url.pathname === '/api/auth/login' && request.method === 'POST') {
      return await handleLogin(request);
    }
    
    // For other endpoints, proxy to Supabase REST API
    const supabasePath = url.pathname.replace('/api', '/rest/v1');
    const targetUrl = new URL(supabasePath, SUPABASE_URL);
    
    // Copy query parameters
    for (const [key, value] of url.searchParams) {
      targetUrl.searchParams.set(key, value);
    }
    
    // Copy headers
    const headers = new Headers(request.headers);
    headers.set('apikey', SUPABASE_ANON_KEY);
    headers.set('Authorization', `Bearer ${SUPABASE_ANON_KEY}`);
    headers.set('Host', targetUrl.host);
    
    // Handle preflight requests
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
          'Access-Control-Max-Age': '86400',
        },
      });
    }

    try {
      const response = await fetch(targetUrl, {
        method: request.method,
        headers: headers,
        body: request.method !== 'GET' && request.method !== 'HEAD' ? request.body : null,
      });

      const corsHeaders = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      };

      // Copy response headers
      const responseHeaders = new Headers(response.headers);
      for (const [key, value] of Object.entries(corsHeaders)) {
        responseHeaders.set(key, value);
      }

      return new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers: responseHeaders,
      });
    } catch (error) {
      return new Response(JSON.stringify({ error: 'Proxy error: ' + error.message }), {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      });
    }
  },
};

async function handleLogin(request) {
  try {
    const body = await request.json();
    const { username, password } = body;
    
    // Query Supabase for user by username
    const supabaseUrl = new URL('/rest/v1/users?username=eq.' + encodeURIComponent(username) + '&select=*', SUPABASE_URL);
    
    const response = await fetch(supabaseUrl, {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
    });
    
    const users = await response.json();
    
    if (!users || users.length === 0) {
      return new Response(JSON.stringify({ error: 'Invalid username or password' }), {
        status: 401,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      });
    }
    
    const user = users[0];
    
    // Simple password verification (in production, use bcrypt on backend)
    const crypto = require('crypto');
    const passwordHash = crypto.createHash('sha256').update(password).digest('hex');
    
    if (passwordHash !== user.password_hash) {
      return new Response(JSON.stringify({ error: 'Invalid username or password' }), {
        status: 401,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      });
    }
    
    // Return user data (in production, return a JWT token)
    return new Response(JSON.stringify({
      user: {
        id: user.id,
        fullName: user.full_name,
        role: user.role,
      },
      token: SUPABASE_ANON_KEY, // Using anon key as temporary token
    }), {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: 'Login error: ' + error.message }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  }
}
