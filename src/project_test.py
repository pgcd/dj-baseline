# Basic test to confirm the project was started as expected;
# real tests should live with their apps, as usual.
from django.test import TestCase


class NewProjectTests(TestCase):
    def test_project_was_built(self):
        self.assertTrue(True)
