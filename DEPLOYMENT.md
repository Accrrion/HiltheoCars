# 🚀 Deployment Guide

## Quick Deploy Options

### Option 1: Netlify (Frontend) + Render (Backend) - RECOMMENDED

---

## 📦 STEP 1: Deploy Backend to Render

1. **Push your code to GitHub**
   - Make sure `.env` is in `.gitignore` (already done)
   - Commit and push all changes

2. **Go to [render.com](https://render.com)**
   - Sign up with GitHub
   - Click "New +" → "Web Service"
   - Connect your GitHub repo

3. **Configure the service:**
   ```
   Name: hiltheo-backend
   Environment: Node
   Build Command: npm install
   Start Command: npm start
   ```

4. **Add Environment Variables:**
   ```
   GOOGLE_CLIENT_ID=YOUR_GOOGLE_CLIENT_ID
   GOOGLE_CLIENT_SECRET=YOUR_GOOGLE_CLIENT_SECRET
   JWT_SECRET=hiltheo-synergy-secure-jwt-key-2024-x7k9m2p5
   CLIENT_URL=https://hiltheo-frontend.netlify.app  (update after frontend deploy)
   ```

5. **Click "Create Web Service"**
   - Wait for deployment
   - Copy the URL: `https://hiltheo-backend.onrender.com`

---

## 🌐 STEP 2: Deploy Frontend to Netlify

### Method A: Drag & Drop (Fastest)

1. **Create a `.env.production` file** in the root:
   ```
   VITE_API_URL=https://hiltheo-backend.onrender.com/api
   ```

2. **Build the project:**
   ```bash
   npm run build
   ```

3. **Go to [netlify.com](https://netlify.com)**
   - Drag the `dist/` folder to deploy
   - Site will be live instantly!

### Method B: GitHub Integration (Better for updates)

1. **Push frontend to GitHub** (separate repo or same repo)

2. **Go to [netlify.com](https://netlify.com)**
   - "Add new site" → "Import an existing project"
   - Choose your GitHub repo

3. **Build settings:**
   ```
   Build command: npm run build
   Publish directory: dist
   ```

4. **Add Environment Variable:**
   ```
   VITE_API_URL=https://hiltheo-backend.onrender.com/api
   ```

5. **Click "Deploy Site"**

---

## ⚠️ IMPORTANT: Update Google OAuth

After deployment, you MUST update Google OAuth settings:

1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Edit your OAuth 2.0 credentials
3. Add these to "Authorized JavaScript origins":
   - `https://your-frontend-url.netlify.app`
   - `https://hiltheo-backend.onrender.com`
4. Add to "Authorized redirect URIs":
   - `https://your-frontend-url.netlify.app`

---

## 🔧 Alternative: Vercel (Frontend)

If Netlify doesn't work:

1. Go to [vercel.com](https://vercel.com)
2. Import your GitHub repo
3. Framework Preset: Vite
4. Build Command: `npm run build`
5. Output Directory: `dist`
6. Add Environment Variable: `VITE_API_URL`

---

## 🧪 Test Your Deployment

1. Visit your frontend URL
2. Try logging in with test credentials
3. Check browser console for errors
4. Verify backend is responding at `https://your-backend.onrender.com/api/health`

---

## 📋 Environment Variables Summary

### Backend (Render)
```
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_secret
JWT_SECRET=your_jwt_secret
CLIENT_URL=https://your-frontend.netlify.app
```

### Frontend (Netlify/Vercel)
```
VITE_API_URL=https://your-backend.onrender.com/api
```

---

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| CORS errors | Update `CLIENT_URL` in backend env vars |
| Login not working | Check `VITE_API_URL` is correct |
| Google OAuth fails | Add deployed URLs to Google Console |
| 404 on refresh | Add `_redirects` file in `public/` |

---

## 📁 Create `_redirects` file for Netlify

Create `public/_redirects`:
```
/* /index.html 200
```

This fixes the "404 on page refresh" issue with React Router.
