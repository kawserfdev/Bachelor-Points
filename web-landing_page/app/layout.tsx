import type { Metadata } from "next";
import { Geist, Geist_Mono, Inter } from "next/font/google";
import "./globals.css";
import { cn } from "@/lib/utils";

const inter = Inter({ subsets: ['latin'], variable: '--font-sans' });

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

import { ThemeProvider } from "@/components/theme-provider";

export const metadata: Metadata = {
  title: "BachelorPoints - Simplify Your Mess Life",
  description: "The ultimate BachelorPoints and meal expense tracking platform for bachelor messes and hostels.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      suppressHydrationWarning
      className={cn("h-full", "antialiased", geistSans.variable, geistMono.variable, "font-sans", inter.variable)}
    >
      <head>
        {/* Auth-aware redirect: if the Flutter app has marked the user as
            authenticated, skip the landing page and go straight to the app.
            Runs synchronously before hydration to avoid a flash of the landing.
            Uses location.replace() so the landing page is not kept in history,
            keeping the browser Back button clean. */}
        <script dangerouslySetInnerHTML={{
          __html: `
          (function () {
            try {
              if (localStorage.getItem('bp_authed') === 'true') {
                window.location.replace('/app/');
              }
            } catch (e) { /* localStorage unavailable — stay on landing */ }
          })();
        ` }} />
      </head>
      <body className="min-h-full flex flex-col">
        <ThemeProvider
          attribute="class"
          defaultTheme="dark"
          enableSystem
          disableTransitionOnChange
        >
          {children}
        </ThemeProvider>
      </body>
    </html>
  );
}
