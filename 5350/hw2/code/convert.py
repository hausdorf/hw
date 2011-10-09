

DEV = 'hw1-dev'
TRAIN = 'hw1-train'
TEST = 'hw1-test'

if __name__ == '__main__':
    curr = TEST
    f = open(curr)
    g = open(curr + '-p', 'w')

    for line in f.readlines():
        counter = 0

        for feature in line.strip().split():
            if counter == 0:
                #print '%s' % feature,
                g.write('%s' % feature)
            else:
                if float(feature) == 0:
                    continue
                #print '\t%s:%s' % (str(counter), feature),
                g.write('\t%s:%s' % (str(counter), feature))

            counter += 1
        #print
        g.write('\n')

    f.close()
    g.close()
