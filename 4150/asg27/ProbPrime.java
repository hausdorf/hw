import java.math.BigInteger;
import java.util.Random;

public class ProbPrime {
    private static final int BIT_LEN = 8;
    private static final int REPETITIONS = 10000;
    private static final int RESULTS_LEN = 4;
    private static final int CONFIDENCE_INTERVAL = 16;

    public static void main(String[] args) {
        Random generator = new Random(System.nanoTime());
        BigInteger rand;
        BigInteger witness;

        int[] tally = new int[RESULTS_LEN];
        int result;

        for(int i=0; i<REPETITIONS; i++) {
            if(i % 100 == 0)
                System.out.println(i);
            rand = new BigInteger(BIT_LEN, generator);
            while(true) {
                if(rand.mod(new BigInteger("2")).compareTo(new BigInteger("0")) == 0)
                    rand = new BigInteger(BIT_LEN, generator);
                else if(rand.mod(new BigInteger("3")).compareTo(new BigInteger("0")) == 0)
                    rand = new BigInteger(BIT_LEN, generator);
                else if(rand.mod(new BigInteger("5")).compareTo(new BigInteger("0")) == 0)
                    rand = new BigInteger(BIT_LEN, generator);
                else
                    break;
            }
            //System.out.println("Rand " + rand.toString());

            //witness = new BigInteger(rand.bitLength(), generator);
            /*if((result = testPrimality(rand)) > 0) {
                tally[result] += 1;
            }*/
            result = testPrimality(rand);
            // Prime, not reported
            if(result == 1 && rand.isProbablePrime(CONFIDENCE_INTERVAL))
                tally[1]++;
            // Not prime, not reported
            else if(result == 1 && !rand.isProbablePrime(CONFIDENCE_INTERVAL))
                tally[2]++;
            // Prime, reported
            else if(result == 0 && rand.isProbablePrime(CONFIDENCE_INTERVAL)) {
                tally[3]++;
            }
            // Not Prime, reported
            else {
                tally[0]++;
            }
        }

        for(int i=0; i<RESULTS_LEN; i++) {
            System.out.println("Tally " + i + " " + tally[i]);
        }
    }

    // Returns the int it failed on
    public static int testPrimality(BigInteger b) {
        if(b.compareTo(new BigInteger("0")) == 0)
            b = b.add(new BigInteger("1"));

        BigInteger constant = new BigInteger ("1");
        BigInteger test1 = new BigInteger("2");
        BigInteger test2 = new BigInteger("3");
        BigInteger test3 = new BigInteger("5");

        BigInteger bcopy = new BigInteger(b.toString());
        bcopy = bcopy.subtract(constant);

        /*System.out.println(b.toString());
        System.out.println("Test1: " + test1.modPow(b.subtract(constant), b).toString());
        System.out.println("Test2: " + test2.modPow(b.subtract(constant), b).toString());
        System.out.println("Test3: " + test3.modPow(b.subtract(constant), b).toString());*/

        if(test1.modPow(bcopy, b).compareTo(constant)==0) {
            if(test2.modPow(bcopy, b).compareTo(constant)==0) {
                if(test3.modPow(bcopy, b).compareTo(constant)==0) {
                    return 0;
                }
            }
        }
        return 1;
    }
}
