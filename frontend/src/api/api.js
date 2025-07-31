import axios from "axios";

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL, // set via .env file
});

export default api;
