/*
 * Any time you add a test, you're going to have to add the method, too.
 */

void main (string[] args) {
	Test.init( ref args );
	ClientTest.add_tests();
	Test.run();
}