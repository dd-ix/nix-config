# from django.contrib.auth.models import Group # For Netbox < 4.0.0
from netbox.authentication import Group # For Netbox >= 4.0.0

class AuthFailed(Exception):
    pass

def add_groups(response, user, backend, *args, **kwargs):
    try:
        groups = response['groups']
    except KeyError:
        pass

    # Add all groups from oAuth token
    for group in groups:
        group, created = Group.objects.get_or_create(name=group)
        # group.user_set.add(user) # For Netbox < 4.0.0
        user.groups.add(group) # For Netbox >= 4.0.0

def remove_groups(response, user, backend, *args, **kwargs):
    try:
        groups = response['groups']
    except KeyError:
        # Remove all groups if no groups in oAuth token
        user.groups.clear()
        pass

    # Get all groups of user
    user_groups = [item.name for item in user.groups.all()]
    # Get groups of user which are not part of oAuth token
    delete_groups = list(set(user_groups) - set(groups))

    # Delete non oAuth token groups
    for delete_group in delete_groups:
        group = Group.objects.get(name=delete_group)
        # group.user_set.remove(user) # For Netbox < 4.0.0
        user.groups.remove(group) # For Netbox >= 4.0.0


def set_roles(response, user, backend, *args, **kwargs):
    # Remove Roles temporary
    user.is_superuser = False
    user.is_staff = False
    try:
        groups = response['groups']
    except KeyError:
        # When no groups are set
        # save the user without Roles
        user.save()
        pass

    # Set roles is role (superuser or staff) is in groups
    user.is_superuser = True if 'superusers' in groups else False
    user.is_staff = True if 'staff' in groups else False
    user.save()
