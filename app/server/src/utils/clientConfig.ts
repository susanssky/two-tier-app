export const clientConfig = {
  connectionString: process.env.DATABASE_URL!,
  // ssl: false,
  ssl: {
    rejectUnauthorized: false,
  },
}
