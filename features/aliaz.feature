Feature: Aliaz
  In order to extend command line tools
  As a developer
  I want to add and remove custom aliases to command line apps

  Scenario: Add alias to app
    When I run `aliaz add app_name.alias some_alias`
    Then the exit status should be 0
    And the output should contain:
    """
    Alias 'alias' with value 'some_alias' was created successfully!
    """

  Scenario: Add alias to app with value with spaces
    When I run `aliaz add app_name.alias some alias value`
    Then the exit status should be 0
    And the output should contain:
    """
    Alias 'alias' with value 'some alias value' was created successfully!
    """

  Scenario: Add alias to app with dotted alias name
    When I run `aliaz add app_name.alias.dotted.alias alias value`
    Then the exit status should be 0
    And the output should contain:
    """
    Alias 'alias.dotted.alias' with value 'alias value' was created successfully!
    """
  Scenario: I am trying to add alias for app but i forgot the name or value of the alias
    When I run `aliaz add app_name alias value`
    Then the exit status should be 1
    And the output should contain:
    """
    Ups ... you miss to add the name or value of the alias :)
    Try something like this: 'aliaz add app.alias value' :)
    """

  Scenario: Remove alias from app
    When I run `aliaz add app_name.alias some_alias`
    And I run `aliaz remove app_name alias`
    Then the exit status should be 0
    And the output should contain:
    """
    Alias 'alias' was removed successfully!
    """

  Scenario: Remove alias from not existing app
    When I run `aliaz add app_name.alias some_alias`
    And I run `aliaz remove app_name1 alias`
    Then the exit status should be 1
    And the output should contain:
    """
    The app 'app_name1' does not exist!
    """

  Scenario: Get all aliases in readable format
    When I run `aliaz add app_name.alias some_alias`
    And I run `aliaz aliases`
    Then the exit status should be 0
    And the output should contain:
    """
    ---
    app_name:
      alias: some_alias
    """

  Scenario: Get all aliases in readable format for specific app
    When I run `aliaz add app_name.alias some_alias`
    And I run `aliaz add app_name1.alias1 some_alias1`
    And I run `aliaz aliases app_name1`
    Then the exit status should be 0
    And the output should not contain:
    """
    app_name:
      alias: some_alias
    """

  Scenario: Get all aliases in bash format
    When I run `aliaz add app_name.alias some_alias`
    And I run `aliaz aliases --bash`
    Then the exit status should be 0
    And the output should contain:
    """
    app_name() {
    """
