/*
 * TestClasses.vala
 *
 * The Ambition Web Framework
 * http://www.ambitionframework.org
 *
 * Copyright 2012-2013 Sensical, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

public class TestStringObject : Object {
	public string foo { get; set; }
}

public class TestStringUnderscoreObject : Object {
	public string foo_baz { get; set; default = "bar"; }
}

public class TestIntObject : Object {
	public int foo { get; set; }
}

public class TestDoubleObject : Object {
	public double foo { get; set; }
}

public class TestBoolObject : Object {
	public bool foo { get; set; }
}

public class TestStringArrayObject : Object {
	public string[] foo { get; set; default = { "bar", "baz" }; }
}

public class TestStringArrayListObject : Object {
	public Gee.ArrayList<string> foo { get; set; default = new Gee.ArrayList<string>(); }

	public TestStringArrayListObject() {
		foo.add("bar");
		foo.add("baz");
	}
}

public class TestObjectObject : Object {
	public Object bar { get; set; }

	public TestObjectObject() {}
	public TestObjectObject.with_data() { this.bar = new TestStringArrayObject(); }
}

public class TestEverythingObject : Object {
	public string foo_baz { get; set; }
	public int some_int { get; set; }
	public bool is_something { get; set; }
	public string[] list_of_things { get; set; }
	public TestEverythingContainerObject super_container { get; set; }

	public TestEverythingObject() {}
	public TestEverythingObject.with_data() {
		this.foo_baz = "bar";
		this.some_int = 42;
		this.is_something = false;
		this.list_of_things = { "thing", "another", "so wow" };
		this.super_container = new TestEverythingContainerObject();
	}
}

public class TestEverythingContainerObject : Object {
	public TestStringArrayListObject container { get; set; default = new TestStringArrayListObject(); }
	public string example { get; set; default = "I am here"; }
}

public class TestIgnoreObject : Object {
	public string not_ignored { get; set; default = "woohoo"; }
	[Description( blurb = "ignore" )]
	public string ignored { get; set; default = "boo"; }
}

public class TestRenameObject : Object {
	[Description( nick = "renamed" )]
	public string something { get; set; default = "woohoo"; }
}