using System;

class TOMS423_PRB
{
    static void Main()
    {
        Console.WriteLine("TOMS423_PRB");
        Console.WriteLine("  DECOMP factors a general matrix;");
        Console.WriteLine("  SOLVE solves a factored linear system;");
        Console.WriteLine();

        int ndim = 4;
        int n = 3;

        Console.WriteLine("  The matrix dimension NDIM =     {0}", ndim);
        Console.WriteLine("  The number of equations is N =     {0}", n);
        Console.WriteLine();
        Console.WriteLine("  The matrix A:");
        Console.WriteLine();

        double[,] A = {
            {1.0, 2.0, 3.0},
            {4.0, 5.0, 6.0},
            {7.0, 8.0, 0.0}
        };

        for (int i = 0; i < n; i++)
        {
            for (int j = 0; j < n; j++)
                Console.Write(" {0,10:F5}", A[i, j]);
            Console.WriteLine();
        }

        Console.WriteLine();
        Console.WriteLine("  The right hand side B is ");
        Console.WriteLine();

        double[] B = { 14.0, 32.0, 23.0 };

        for (int i = 0; i < n; i++)
            Console.WriteLine(" {0,10:F4}", B[i]);

        Console.WriteLine();
        Console.WriteLine("  Factor the matrix");
        Console.WriteLine();

        // Perform LU decomposition using Doolittle's method with partial pivoting
        int[] pivot;
        double[,] LU = LUFactor(A, n, out pivot);

        // Compute the determinant from LU
        double det = 1.0;
        for (int i = 0; i < n; i++)
            det *= LU[i, i];
        // Adjust for row exchanges
        for (int i = 0; i < n; i++)
            if (pivot[i] != i)
                det *= -1;

        Console.WriteLine("  Matrix determinant = {0,10:F4}", det);
        Console.WriteLine();
        Console.WriteLine("  Solve the linear system.");
        Console.WriteLine();
        Console.WriteLine("  SOLVE returns the solution:");
        Console.WriteLine("  (Should be (1,2,3))");
        Console.WriteLine();

        double[] X = LUSolve(LU, pivot, B, n);
        for (int i = 0; i < n; i++)
            Console.WriteLine(" {0,10:F5}", X[i]);
    }

    static double[,] LUFactor(double[,] A, int n, out int[] pivot)
    {
        double[,] LU = (double[,])A.Clone();
        pivot = new int[n];

        for (int i = 0; i < n; i++)
            pivot[i] = i;

        for (int k = 0; k < n; k++)
        {
            // Find pivot
            int max = k;
            for (int i = k + 1; i < n; i++)
                if (Math.Abs(LU[i, k]) > Math.Abs(LU[max, k]))
                    max = i;

            if (max != k)
            {
                // Swap rows
                for (int j = 0; j < n; j++)
                {
                    double temp = LU[k, j];
                    LU[k, j] = LU[max, j];
                    LU[max, j] = temp;
                }
                int t = pivot[k];
                pivot[k] = pivot[max];
                pivot[max] = t;
            }

            for (int i = k + 1; i < n; i++)
            {
                LU[i, k] /= LU[k, k];
                for (int j = k + 1; j < n; j++)
                    LU[i, j] -= LU[i, k] * LU[k, j];
            }
        }

        return LU;
    }

    static double[] LUSolve(double[,] LU, int[] pivot, double[] B, int n)
    {
        double[] x = new double[n];

        // Apply pivot
        for (int i = 0; i < n; i++)
            x[i] = B[pivot[i]];

        // Forward substitution (Ly = b)
        for (int i = 0; i < n; i++)
            for (int j = 0; j < i; j++)
                x[i] -= LU[i, j] * x[j];

        // Back substitution (Ux = y)
        for (int i = n - 1; i >= 0; i--)
        {
            for (int j = i + 1; j < n; j++)
                x[i] -= LU[i, j] * x[j];
            x[i] /= LU[i, i];
        }

        return x;
    }
}
