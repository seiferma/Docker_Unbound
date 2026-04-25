from testcontainers.core.container import DockerContainer
from testcontainers.core.wait_strategies import HealthcheckWaitStrategy

import dns.resolver
import socket

def to_ip(hostname):
    return socket.gethostbyname(hostname)

def create_resolver(subject : DockerContainer) -> dns.resolver.Resolver:
    ip = to_ip(subject.get_container_host_ip())
    mapped_port = subject.get_exposed_port(53)
    resolver = dns.resolver.Resolver(configure=False)
    resolver.nameservers = [ip]
    resolver.nameserver_ports = {ip: mapped_port}
    return resolver

def test_start(img_name):
    # test healthy startup without any config
    with DockerContainer(img_name).waiting_for(HealthcheckWaitStrategy()) as subject:
        assert True

def test_recursive_resolution(img_name):
    # test successful resolution using recursive mode
    with DockerContainer(img_name).with_env("ACCESS_CONTROL_1", "0.0.0.0/0 allow").with_env("ACCESS_CONTROL_2", "::0/0 allow").with_exposed_ports("53/udp").waiting_for(HealthcheckWaitStrategy()) as subject:
        resolver = create_resolver(subject)
        answer = resolver.query("google.com")
        assert answer is not None
        assert len(answer) > 0

def test_forwarding_resolution(img_name):
    # test successful resolution using forwarding mode
    with DockerContainer(img_name).with_env("ACCESS_CONTROL_1", "0.0.0.0/0 allow").with_env("ACCESS_CONTROL_2", "::0/0 allow").with_env("FORWARD_ADDR_1", "9.9.9.9").with_exposed_ports("53/udp").waiting_for(HealthcheckWaitStrategy()) as subject:
        execResult = subject.exec("cat /etc/unbound/forward-zone.conf")
        assert execResult.exit_code == 0
        assert "9.9.9.9" in str(execResult.output).strip()
        resolver = create_resolver(subject)
        answer = resolver.query("google.com")
        assert answer is not None
        assert len(answer) > 0

def test_private_domains(img_name):
    # test successful resolution using forwarding mode
    with DockerContainer(img_name).with_env("ACCESS_CONTROL_1", "0.0.0.0/0 allow").with_env("ACCESS_CONTROL_2", "::0/0 allow").with_env("PRIVATE_DOMAIN_1", "example.org").with_exposed_ports("53/udp").waiting_for(HealthcheckWaitStrategy()) as subject:
        execResult = subject.exec("cat /etc/unbound/private-domains.conf")
        assert execResult.exit_code == 0
        assert "example.org" in str(execResult.output).strip()
        resolver = create_resolver(subject)
        answer = resolver.query("google.com")
        assert answer is not None
        assert len(answer) > 0
