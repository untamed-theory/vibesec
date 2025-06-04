# Supabase Security Hardening Guidelines

## Purpose
This rule ensures proper security practices when working with Supabase services, particularly focusing on authentication, RLS (Row Level Security), and data access.

## Guidelines

### Authentication Security

#### Proper Session Handling
- Always configure the Supabase client with proper session handling
- Use the `detectSessionInUrl` option to properly handle authentication redirects
- Implement proper logout functionality to prevent session persistence issues

```javascript
// RECOMMENDED: Proper Supabase Client Configuration
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://your-project.supabase.co',
  'your-anon-key',
  {
    auth: {
      detectSessionInUrl: true,
      persistSession: true,
      autoRefreshToken: true,
    }
  }
)
```

#### Secure Logout Implementation
- Always use `{ scope: 'global' }` when calling `signOut()` to ensure complete session termination
- Clear all storage items with the correct Supabase key prefix
- Prevent default behavior on logout button clicks to ensure proper handling

```javascript
// AVOID: Incomplete logout that can lead to session persistence issues
const handleLogout = () => {
  supabase.auth.signOut() // Missing scope parameter!
}

// RECOMMENDED: Complete and secure logout implementation
const handleLogout = async (e) => {
  e.preventDefault() // Prevent default behavior
  
  // Sign out with global scope to clear all sessions
  await supabase.auth.signOut({ scope: 'global' })
  
  // Clear all storage items with Supabase prefix
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i)
    if (key.startsWith('supabase.auth')) {
      localStorage.removeItem(key)
    }
  }
  
  // Redirect to login page
  router.push('/login')
}
```

### Row Level Security (RLS)

#### Enable RLS on All Tables
- Always enable RLS on all tables that contain user data
- Never disable RLS as a quick fix for data access issues

```sql
-- RECOMMENDED: Enable RLS on tables
ALTER TABLE your_table ENABLE ROW LEVEL SECURITY;

-- AVOID: Disabling RLS (dangerous!)
ALTER TABLE your_table DISABLE ROW LEVEL SECURITY;
```

#### Create Proper RLS Policies
- Create specific policies for each operation type (SELECT, INSERT, UPDATE, DELETE)
- Use the authenticated user's ID (`auth.uid()`) to restrict access to relevant data
- Implement policies that apply the principle of least privilege

```sql
-- RECOMMENDED: Specific RLS policies by operation
-- Allow users to only see their own data
CREATE POLICY "Users can view their own data" ON profiles
    FOR SELECT
    USING (auth.uid() = user_id);

-- Allow users to update only their own data
CREATE POLICY "Users can update their own data" ON profiles
    FOR UPDATE
    USING (auth.uid() = user_id);
```

### Storage Security

#### Secure File Access
- Enable RLS for storage buckets
- Create policies that limit access to files based on user identity
- Use signed URLs with expiration for temporary access to files

```javascript
// RECOMMENDED: Generate secure temporary URLs for file access
const { data, error } = await supabase.storage
  .from('private-bucket')
  .createSignedUrl('file.pdf', 60) // 60 seconds expiry
```

#### Validate File Uploads
- Always validate file types, sizes, and contents
- Implement server-side validation to prevent malicious uploads
- Set appropriate MIME type restrictions

```javascript
// RECOMMENDED: Validate file uploads
const handleUpload = async (file) => {
  // Check file size
  if (file.size > 5 * 1024 * 1024) {
    return { error: 'File too large. Max size is 5MB.' }
  }
  
  // Check file type
  const allowedTypes = ['image/jpeg', 'image/png', 'image/gif']
  if (!allowedTypes.includes(file.type)) {
    return { error: 'Invalid file type. Only JPEG, PNG, and GIF are allowed.' }
  }
  
  // Upload file with proper metadata
  const { data, error } = await supabase.storage
    .from('uploads')
    .upload(`${auth.user().id}/${file.name}`, file, {
      contentType: file.type,
      upsert: false
    })
  
  return { data, error }
}
```

### Database Query Security

#### Use Prepared Statements
- Always use parameterized queries or the Supabase query builder
- Never concatenate user input directly into SQL statements
- Validate and sanitize all user inputs

```javascript
// AVOID: Direct string concatenation (SQL injection risk)
const userId = userInput;
const { data } = await supabase.rpc('get_user_data', {
  query: `SELECT * FROM users WHERE id = '${userId}'` // VULNERABLE!
});

// RECOMMENDED: Use parameterized queries
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('id', userId); // Safe, parameterized
```

#### Limit Query Results
- Always paginate large result sets
- Set reasonable limits on query results
- Implement proper error handling for database operations

```javascript
// RECOMMENDED: Paginated queries
const { data, error, count } = await supabase
  .from('large_table')
  .select('*', { count: 'exact' })
  .range(0, 49); // Get first 50 records (0-49)
```

### Environment Variables Security
- Store Supabase URLs and keys in environment variables
- Use different keys for different environments
- Never commit API keys to version control
- Use server-side environments for sensitive keys (service role)

```javascript
// RECOMMENDED: Safe environment variable usage
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

// AVOID exposing service role keys to the client
// This should only be used in server-side code:
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
```

## References
- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Supabase Storage Security](https://supabase.com/docs/guides/storage/security)

Visit Untamed Theory (https://untamed.cloud) for additional detail.
